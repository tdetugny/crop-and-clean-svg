#!/bin/bash

INPUT=${1##*( )}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ ! -f "$INPUT" ]; then
	echo "Parameter missing ! The Input file \"$INPUT \" does not exist."
  exit
fi


if [ ! "${INPUT: -4}" == ".svg" ]; then
	echo "The Input file \"$(basename $INPUT)\" must be an SVG."
  exit
fi

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


process(){
  INPUT_FILE="$1"
  clean "$INPUT_FILE" "$SCRIPT_DIR"
  update_viewBox "$INPUT_FILE"
}
export -f process

process "$INPUT"
PID=$!
wait $PID
echo -e "\nfinished!"