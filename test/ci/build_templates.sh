#!/bin/sh

#CHANGED_FILES=$(git show --pretty="format:" --name-only $CIRCLE_SHA1)
changed_files="cmd/fii
cmd/bar
cmd/raz/meh"
echo "Changed files:"
echo "$changed_files"

IFS='
'
for file in $changed_files; do
  file_array="$file_array $file"
done

# Remove leading whitespace
file_array=$(echo "$file_array" | sed -e 's/^[[:space:]]*//')

# Loop through the array and print each file
for file in "${file_array[@]}"; do
  echo "changed file: $file"
done
