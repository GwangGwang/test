#!/bin/sh

#CHANGED_FILES=$(git show --pretty="format:" --name-only $CIRCLE_SHA1)
changed_files="cmd/fii
cmd/bar
cmd/raz/meh"
echo "Changed files:"
echo "$changed_files"

while read -r line; do
     echo "changed file: $line"
done < changed_files

