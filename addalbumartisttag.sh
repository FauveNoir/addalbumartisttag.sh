#!/bin/env sh

if [ $# -eq 0 ]; then
	DIR=.
else
	DIR=$1
fi

find $DIR -type f -name "*.flac"  > temporary-list-file


while read g; do
	ls "$g"
	echo "Processing \"$g\""
	metaflac --export-tags-to="$g"-metatag-temp "$g"
	if grep -q --ignore-case "^ALBUMARTIST=[^$]" "$g"-metatag-temp ; then
		echo "There is noting to do for this file."
	else
		echo "An “ALBUMARTIST” will be add.\n"
		metaflac --set-tag="ALBUMARTIST=`more "$g"-metatag-temp | grep --ignore-case -e '^ARTIST' | sed 's/^ARTIST=//'`" "$g"
	fi

	rm "$g"-metatag-temp
	ls "$g"
done < temporary-list-file

rm temporary-list-file
