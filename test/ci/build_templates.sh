#!/bin/sh

CHANGED_FILES=$(git show --pretty="format:" --name-only $CIRCLE_SHA1)
echo "Changed files:"
echo "$CHANGED_FILES"

CHANGED_SERVICE=$(echo "CHANGED_FILES" | grep '^cmd/' | sed 's/\/.*//g' | sort -u)
echo "Changed services:"
echo "$CHANGED_SERVICE"
