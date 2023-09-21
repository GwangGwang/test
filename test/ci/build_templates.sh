#!/bin/sh

CHANGED_FILES=$(git diff --name-only $CIRCLE_PREVIOUS_SHA1..$CIRCLE_SHA1)
echo "Changed files:"
echo "$CHANGED_FILES"
