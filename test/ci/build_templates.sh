#!/bin/sh

#CHANGED_FILES=$(git show --pretty="format:" --name-only $CIRCLE_SHA1)
CHANGED_FILES="fii
bar
raz"
echo "Changed files:"
echo "$CHANGED_FILES"

CHANGED_SERVICE=$(echo "$CHANGED_FILES" | grep '^cmd/' | cut -f2 -d'/' | sort -u)
echo "Changed services:"
echo "$CHANGED_SERVICE"

echo "$CHANGED_SERVICE" >> "/tmp/test"


