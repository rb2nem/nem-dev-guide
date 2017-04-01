#!/bin/bash

set -eu
output_file=$1
[[ -f $output_file ]] && echo "$output_file already exists, not overwriting!" && exit 1

shift
request="$@"

tmp_file=$(tempfile)

# do request and collect output
http --verbose --pretty all --style monokai  $request | ansi2html.sh  --body-only --bg=dark --palette solarized > $tmp_file ||  echo "request failure" && exit 2; 

# wrap output for inclusion in a page
( echo "<pre><div class=\"httpie\">\$ http $request</div>";
cat  $tmp_file;
echo "</pre>"; ) > $output_file
rm $tmp_file

