#!/bin/sh

#CHANGED_FILES=$(git show --pretty="format:" --name-only $CIRCLE_SHA1)
changed_files="cmd/fii
cmd/bar
cmd/raz/meh"
echo "Changed files:"
echo "$changed_files"

#for file in $changed_files; do
 # file_array="$file_array$file\n"
#done

# Remove trailing newline
#file_array=$(echo "$file_array" | sed -e '$ d')

# Loop through the array and print each file
for file in $changed_files; do
  echo "changed file: $file"
done

templates="message-wall-2023-10-01-fadf
fingerprinter-2024-01-01-fafd
"
for line in $templates; do
  echo "target line: $line"
  service_name=$(echo "$line" | sed -E 's/(-[0-9]{4}-[0-9]{2}-[0-9]{2}).*//')
  echo "service name: $service_name"
done



export BUILDPLATFORM=linux/amd64
export TARGETPLATFORM=linux/amd64
make build-events-image-dev