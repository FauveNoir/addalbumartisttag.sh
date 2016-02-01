#!/bin/env sh

if [ $# -eq 0 ]; then
	DIR=.
else
	DIR=$1
fi

# Generating lists of files wich will be processed
find $DIR -type f -name "*.flac" > temporary-flac-list-file
find $DIR -type f -name "*.mp3"  > temporary-mp3-list-file
find $DIR -type f -name "*.ogg"  > temporary-ogg-list-file


# Processing flac files
while read g; do
	echo "Processing \"$g\""
	metaflac --export-tags-to="$g"-metatag-temp "$g"
	if grep --quiet --ignore-case "^ALBUMARTIST=[^$]" "$g"-metatag-temp ; then
		echo "There is noting to do for this file."
	else
		echo "An “ALBUMARTIST” will be add."
		metaflac --remove-tag=ALBUMARTIST "$g"
		#metaflac --set-tag="ALBUMARTIST=`more "$g"-metatag-temp | grep --no-message --ignore-case --regexp='^ARTIST' | sed 's/^ARTIST=//'`" "$g"
		metaflac --set-tag="ALBUMARTIST=`cat "$g"-metatag-temp | grep --no-message --ignore-case --regexp='^ARTIST' | sed 's/^ARTIST=//'`" "$g"
	fi
	rm "$g"-metatag-temp
done < temporary-flac-list-file

#rm temporary-flac-list-file


# Processing mp3 files
while read g; do
	echo "Processing \"$g\""
	ALBUMARTISTTAG=`id3v2 -l "$g" | grep TPE2 | sed 's/TPE2 (Band\/orchestra\/accompaniment): //'`
	ARTISTTAG=`id3v2 -l "$g" | grep TPE1 | sed 's/TPE1 (Lead performer(s)\/Soloist(s)): //'`
	echo $ARTISTTAG
	if [[ -z "$ALBUMARTISTTAG" ]] ; then
		echo "An “ALBUMARTIST” will be add."
		id3v2 --TPE2 "$ARTISTTAG" "$g"
	else
		echo "There is noting to do for this file."
	fi
done < temporary-mp3-list-file

#rm temporary-mp3-list-file
