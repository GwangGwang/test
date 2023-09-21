#!/bin/sh

echo "previous sha1: $CIRCLE_PREVIOUS_SHA1"
echo "current sha1: $CIRCLE_SHA1"

CHANGED_FILES=$(git diff --name-only $CIRCLE_PREVIOUS_SHA1..$CIRCLE_SHA1)
echo "Changed files:"
echo "$CHANGED_FILES"
