#!/usr/bin/env sh

git clone https://github.com/Bearer/bearer
cd bearer/cmd/bearer
go build
cp bearer /usr/bin
cd /usr/bin
chmod +x bearer
