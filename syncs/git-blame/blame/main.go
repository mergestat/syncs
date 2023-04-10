// Package main is a command line tool that runs git blame on all the files in a git repo and stores the output to a CSV file.
//
//	go build -o git-blame-to-csv main.go
//	./git-blame-to-csv /path/to/repo /path/to/output.csv
package main

import (
	"bufio"
	"bytes"
	"context"
	"encoding/csv"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	"github.com/mergestat/gitutils/blame"
	"github.com/mergestat/gitutils/lstree"
)

func printErrAndExit(err error) {
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func main() {
	ctx := context.Background()
	repoPath := os.Args[1]
	outputPath := os.Args[2]
	repoID := os.Getenv("MERGESTAT_REPO_ID")

	if repoPath == "" {
		printErrAndExit(errors.New("repo path is required"))
	}

	if outputPath == "" {
		printErrAndExit(errors.New("output path is required"))
	}

	iter, err := lstree.Exec(ctx, repoPath, "HEAD", lstree.WithRecurse(true))
	if err != nil {
		printErrAndExit(fmt.Errorf("git ls-tree error: %w", err))
	}

	// keeps a list of all the objects in the repo
	var objects []*lstree.Object
	for {
		if o, err := iter.Next(); err != nil {
			if errors.Is(err, io.EOF) {
				break
			} else {
				printErrAndExit(err)
			}
		} else {
			objects = append(objects, o)
		}
	}

	// open/create a file for storing blame output as CSV
	var file *os.File
	if file, err = os.OpenFile(outputPath, os.O_RDWR|os.O_CREATE, 0755); err != nil {
		printErrAndExit(fmt.Errorf("could not create temp file for blame output: %w", err))
	}
	defer file.Close()

	w := csv.NewWriter(file)
	for _, o := range objects {
		// skip non-blob objects
		if o.Type != "blob" {
			continue
		}

		// skip running git blame on binary files
		// first detect if a file is binary or not
		fullPath := filepath.Join(repoPath, o.Path)
		if f, err := os.Open(fullPath); err != nil {
			fmt.Printf("error opening file in repo: %s, %v\n", fullPath, err)
			continue
		} else {
			defer f.Close()

			// only read the first 8kb of the file to detect if it's binary or not
			buffer := make([]byte, 8000)
			var bytesRead int
			if bytesRead, err = f.Read(buffer); err != nil && !errors.Is(err, io.EOF) {
				fmt.Printf("error reading file in repo: %s, %v\n", fullPath, err)
			}

			// See here: https://github.com/go-enry/go-enry/blob/v2.8.2/utils.go#L80 for the implementation of IsBinary
			// basically just looking for a byte(0) in the first portion of the file
			if bytes.IndexByte(buffer[:bytesRead], byte(0)) != -1 {
				fmt.Printf("skipping binary file: %s\n", fullPath)
				continue
			}
		}

		// adjustedBufferSize is larger than the default to support longer lines without error
		// TODO(patrickdevivo) maybe eventually we can make this configurable? Either via an ENV var or a DB setting
		adjustedBufferSize := bufio.MaxScanTokenSize * 30
		res, err := blame.Exec(ctx, repoPath, o.Path, blame.WithScannerBuffer(make([]byte, adjustedBufferSize), adjustedBufferSize))
		if err != nil {
			if exitErr, ok := err.(*exec.ExitError); ok {
				fmt.Printf("error blaming file: %s in repo: %s, %v: %s\n", o.Path, repoPath, err, exitErr.Stderr)
			} else {
				fmt.Printf("error blaming file: %s in repo: %s, %v\n", o.Path, repoPath, err)
			}
			continue
		}

		lineBatch := make([][]string, 0, len(res))
		for lineIdx, blame := range res {
			lineNo := lineIdx + 1

			lineBatch = append(lineBatch, []string{
				repoID,
				blame.Author.Email,
				blame.Author.Name,
				blame.Author.When.Format(time.RFC3339),
				blame.SHA,
				fmt.Sprintf("%d", lineNo),
				blame.Line,
				o.Path,
			})
		}

		if err := w.WriteAll(lineBatch); err != nil {
			printErrAndExit(fmt.Errorf("error writing to csv file: %w", err))
		}
		w.Flush()

		if err := w.Error(); err != nil {
			printErrAndExit(fmt.Errorf("error in csv writer: %w", err))
		}
	}
	w.Flush()
}
