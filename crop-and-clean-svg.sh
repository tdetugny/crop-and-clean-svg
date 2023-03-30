#!/bin/bash

INPUT="./input"
TARGET="./output"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ ! -d "$INPUT" ]; then
	echo "input directory \"$INPUT \" does not exist."
  exit
fi

if [ ! -d "TARGET" ]; then
  echo "$TARGET";
  mkdir -p "$TARGET";
fi;

clean(){
  echo -e "\nclean...";
  OUTPUT_FILE="$1"
  SCRIPT_DIR="$2"
  exec svgo -i "$OUTPUT_FILE" --config "$SCRIPT_DIR/config.js" &
  PID=$!
  wait $PID
}
export -f clean;


update_viewBox(){
  echo -e "\nupdate_viewBox...";
  OUTPUT_FILE="$1"
  exec sed -E -i '0,/viewBox="(\d*\.?\d+|\s)*(31\.9+)(\d*\.?\d+|\s)*"/{s/(31\.9+)/32/}' "$OUTPUT_FILE" &
  PID=$!
  wait $PID
}
export -f update_viewBox;

crop(){
  echo -e "\ncrop...";
  INPUT_FILE="$1"
  OUTPUT_FILE="$2"
  exec inkscape --actions="export-area-drawing;export-margin:0.1;export-type:svg;export-plain-svg; export-do" $INPUT_FILE  --export-filename="$OUTPUT_FILE" &
  PID=$!
  wait $PID
}
export -f crop;

process(){
  INPUT_FILE="$1"
  FILE_NAME="$(basename "$INPUT_FILE")"
  TARGET="$2"

  OUTPUT_FILE="$TARGET/$FILE_NAME";
  crop "$INPUT_FILE" "$OUTPUT_FILE";

  clean "$INPUT_FILE" "$SCRIPT_DIR"
  update_viewBox "$OUTPUT_FILE"
  echo -e "\nfinished!"
}
export -f process

find $INPUT -maxdepth 1 -mindepth 1 -type f -name *.svg -exec bash -c 'process "$0" '"$TARGET" {} \;

