#!/bin/bash
# Generates changelog day by day
export NEXT=$(date +%F)
export SINCE="last month"
export UNTIL=$NEXT
echo "CHANGELOG"
echo ----------------------
git log --no-merges --since="${SINCE}" --until="${UNTIL}" --format="%cd" --date=short | sort -u -r | while read DATE ; do
    echo
    echo [$DATE]
    GIT_PAGER=cat git log --no-merges --format=" * %s" --since="$DATE 00:00:00" --until="$DATE 24:00:00"
done
