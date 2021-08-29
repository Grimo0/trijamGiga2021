#!/bin/bash

# Move to the root dir
SCRIPT_RELATIVE_DIR=$(dirname "${BASH_SOURCE[0]}") 
cd $SCRIPT_RELATIVE_DIR/..

rm -r debug
haxelib run redistHelper hl.debug.hxml -p ajisai -o debug
mv -f "debug/opengl_win/ajisai/" .
rm -r debug
mv -f ajisai debug 
mkdir "debug/imgui"
cp -f "imgui/hlimgui.hdll" "debug/imgui/hlimgui.hdll"
ln -s ../res debug

cd $SCRIPT_RELATIVE_DIR