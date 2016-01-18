#!/bin/env sh

for g in *.flac ;
	do echo "Traitement de \"$g\"" ;
	metaflac --export-tags-to=$g-metatag-temp $g ;
	if grep -q --ignore-case "^ALBUMARTIST=[^$]" $g-metatag-temp ; then
		echo "Il n’y a rien à faire.\n" ;
	else
		echo "Un champ « ALBUMARTIST » sera déffinit.\n" ;
		metaflac --set-tag="ALBUMARTIST=`more $g-metatag-temp | grep --ignore-case -e '^ARTIST' | sed 's/^ARTIST=//'`" $g ;
	fi ;
	rm $g-metatag-temp ;
done
