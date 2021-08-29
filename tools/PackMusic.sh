#!/bin/bash

# Move to the root dir
SCRIPT_RELATIVE_DIR=$(dirname "${BASH_SOURCE[0]}") 
cd $SCRIPT_RELATIVE_DIR/..

if [ ! -d "res/music/" ]; then
	mkdir "res/music"
fi

while read line; do
	IFS=';'					# ; is set as delimiter
	read -ra f <<< "$line"	# read into an array as tokens separated by IFS
	IFS=' '
	if [ ! -f "music/${f[0]}" ]; then
		>&2 echo "Can't find ${f[0]} in music"
		continue
	fi

	if [ ! -f "res/music/${f[1]}.${f[0]##*.}" ] || [ "music/${f[0]}" -nt "res/music/${f[1]}.${f[0]##*.}" ]; then
		echo "Copy music/${f[0]} to res/music/${f[1]}.${f[0]##*.}"
		cp -f "music/${f[0]}" "res/music/${f[1]}.${f[0]##*.}"
	fi
done < "music/PackList.txt"
