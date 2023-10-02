#!/bin/sh

#CHANGED_FILES=$(git show --pretty="format:" --name-only $CIRCLE_SHA1)
CHANGED_FILES="cmd/fii
cmd/bar
cmd/raz/meh"
echo "Changed files:"
echo "$CHANGED_FILES"

CHANGED_SERVICE=$(echo "$CHANGED_FILES" | grep '^cmd/' | cut -f2 -d'/' | sort -u)
echo "Changed services:"
echo "$CHANGED_SERVICE"

TEMPIFS=$IFS
IFS=$'\n'
CHANGED_SERVICES=$CHANGED_SERVICES
IFS=$TEMPIFS

for i in ${CHANGED_SERVICES[@]}
do
  echo "building for $service"
done

mkdir /tmp/ci
chmod 755 /tmp/ci
echo "$CHANGED_SERVICE" >> "/tmp/ci/test"
