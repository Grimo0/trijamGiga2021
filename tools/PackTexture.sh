#!/bin/bash

# Move to the root dir
SCRIPT_RELATIVE_DIR=$(dirname "${BASH_SOURCE[0]}") 
cd $SCRIPT_RELATIVE_DIR/..

while read line; do
	if [ ! -d "art/$line" ]; then
		>&2 echo "Can't find $line in art"
		continue
	fi

	if [ ! -f "res/atlas/$line.atlas" ] || [ "art/$line" -nt "res/atlas/$line.atlas" ]; then
		java -cp tools/runnable-texturepacker.jar com.badlogic.gdx.tools.texturepacker.TexturePacker "art/$line" "res/atlas" "$line"
	fi
done < "art/PackList.txt"
