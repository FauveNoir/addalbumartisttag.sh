#!/bin/env sh

# Deffinition of the working directory, the curren one in any.
if [ $# -eq 0 ]; then
	DIR=.
else
	DIR=$1
fi

# Generating lists of files wich will be processed
find $DIR -type f -name "*.flac" > temporary-flac-list-file
find $DIR -type f -name "*.mp3"  > temporary-mp3-list-file

# Processing flac files
echo "* Processing FLAC files"
while read g; do
	echo "Processing \"$g\""
	metaflac --export-tags-to="$g"-metatag-temp "$g" # Creation of a temporary metainformation file.
	if grep --quiet --ignore-case "^ALBUMARTIST=[^$]" "$g"-metatag-temp ; then # Evaluating if the ALBUMARTIST field is empty.
		echo "There is noting to do for this file."
	else
		echo "An “ALBUMARTIST” will be add."
		metaflac --remove-tag=ALBUMARTIST "$g" # Purging the ALBUMARTIST field before set it.
		metaflac --set-tag="ALBUMARTIST=`cat "$g"-metatag-temp | grep --no-message --ignore-case --regexp='^ARTIST' | sed 's/^ARTIST=//'`" "$g"
	fi
	rm "$g"-metatag-temp # Deleting the temporary metainformation file.
done < temporary-flac-list-file

rm temporary-flac-list-file # Deleting the FLAC files list.


# Processing mp3 files
echo "* Processing mp3 files"
while read g; do
	echo "Processing \"$g\""
	ALBUMARTISTTAG=`id3v2 -l "$g" | grep TPE2 | sed 's/TPE2 (Band\/orchestra\/accompaniment): //'` # Catching the ALBUMARTIST tag before processing the file.
	ARTISTTAG=`id3v2 -l "$g" | grep TPE1 | sed 's/TPE1 (Lead performer(s)\/Soloist(s)): //'` # Catching the ARTIST tag before processing the file.
	echo $ARTISTTAG
	if [[ -z "$ALBUMARTISTTAG" ]] ; then # Evaluating if ALBUMARTIST field is empty.
		echo "An “ALBUMARTIST” will be add." # If yes, the ALBUMARTIST field take the content of the ARTIST tag.
		id3v2 --TPE2 "$ARTISTTAG" "$g"
	else
		echo "There is noting to do for this file."
	fi
done < temporary-mp3-list-file

rm temporary-mp3-list-file # Deleting the mp3 files list.
