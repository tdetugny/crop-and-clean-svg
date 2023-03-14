#!/bin/bash

INPUT="./input"
TARGET="./output"

if [ ! -d "$INPUT" ]; then
	echo "input directory \"$INPUT \" does not exist."
  exit
fi

if [ ! -d "TARGET" ]; then
  echo "$TARGET";
  mkdir -p "$TARGET";
fi;


clean(){
  OUTPUT_FILE="$1"
  echo "======>$OUTPUT_FILE"
  exec svgo -i "$OUTPUT_FILE" --config config.js
}
export -f clean;

crop(){
  INPUT_FILE="$1"
  OUTPUT_FILE="$2"
  exec inkscape --actions="export-area-drawing;export-margin:0.1;export-type:svg;export-plain-svg; export-do" $INPUT_FILE  --export-filename="$OUTPUT_FILE" &
  sleep 1;
}
export -f crop;

process(){
  INPUT_FILE="$1"
  FILE_NAME="$(basename "$INPUT_FILE")"
  TARGET="$2"

  OUTPUT_FILE="$TARGET/$FILE_NAME";
  crop "$INPUT_FILE" "$OUTPUT_FILE";

  clean "$OUTPUT_FILE"
  echo "END"
}
export -f process

find $INPUT -maxdepth 1 -mindepth 1 -type f -name *.svg -exec bash -c 'process "$0" '"$TARGET" {} \;

