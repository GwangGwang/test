#!/bin/sh

#CHANGED_FILES=$(git show --pretty="format:" --name-only $CIRCLE_SHA1)
changed_files="cmd/fii
cmd/bar
cmd/raz/meh"
echo "Changed files:"
echo "$changed_files"

CHANGED_SERVICE=$(echo "$changed_files" | grep '^cmd/' | cut -f2 -d'/' | sort -u)
echo "Changed services:"
echo "$CHANGED_SERVICE"


# Convert the list into an array
IFS=$'\n' read -r -a file_array <<< "$CHANGED_SERVICE"

# Loop through the array and print each file
for file in "${file_array[@]}"; do
  echo "changed file: $file"
done
