from datetime import datetime, timezone, timedelta
import json
import subprocess
import re

re_match_commit = re.compile('^([a-f0-9]{40}) ([0-9]+) .*$')
re_match_author = re.compile('^author (.*)$')
re_match_author_mail = re.compile('^author-mail <(.*)>$')
re_match_author_time = re.compile('^author-time ([0-9]+)$')
re_match_author_timezone = re.compile('^author-tz (-?[0-9]+)$')


def parse_line_porcelain(line):
    """parse_line_porcelain parses a line from source file alongwith all the headers"""

    match = re_match_commit.match(line)
    if match:
        return { 'hash': match.group(1), 'line_number': int(match.group(2)) }
    
    match = re_match_author.match(line)
    if match:
        return { 'name': match.group(1) }

    match = re_match_author_mail.match(line)
    if match:
        return { 'email': match.group(1) }

    match = re_match_author_time.match(line)
    if match:
        return { 'time': int(match.group(1)) }
    
    match = re_match_author_timezone.match(line)
    if match:
        return { 'timezone': int(match.group(1)) }

    return None

def git_blame_porcelain(path_to_file):
    """git_blame_porcelain parses the git blame for the given file"""

    cmd = ["git", "blame", "--line-porcelain", path_to_file]
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = p.communicate()
    if p.returncode != 0:
        raise subprocess.CalledProcessError(p.returncode, cmd, stderr)
    output_lines = stdout.decode("utf-8").split("\n")

    current = {}
    for line in output_lines:
        parsed_line = parse_line_porcelain(line)
        if parsed_line is not None:
            current.update(parsed_line)
        elif len(line) > 0 and line[0] == '\t': # if line starts with a tab character then its the data line
            current.update({ 'line': line.strip() })
            yield current
            current = {}
    
    if current:
        yield current

for info in git_blame_porcelain("cmd/worker/main.go"):
    delta = info['timezone'] if info.get('timezone') else 0

    offset_hours = delta // 100
    offset_minutes = delta % 100
    tz = timezone(timedelta(hours=offset_hours, minutes=offset_minutes))

    info['time'] = datetime.fromtimestamp(info['time'], tz).isoformat()
    print(json.dumps(info))

