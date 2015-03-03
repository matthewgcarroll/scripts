#!/bin/bash
# This script is to move files imported by DropBox from Camera Uploads to a more organized home
# If you have a bunch of files from other sources, use exiftool to rename them to the
# appropriate format - we don't use exiftool to do the final mv, because it tends to make dupes
# http://www.sno.phy.queensu.ca/~phil/exiftool/filename.html
# exiftool -r -d "tmp2/%Y/%Y%m/%Y-%m-%d %H.%M.%S.%%e" "-filename<CreateDate" tmp or
# exiftool -r -d "%Y-%m-%d %H.%M.%S%%-c.%%le" "-filename<CreateDate" .

if [ "$1" = "" ]; then
  echo "Usage: mvuploads.sh source-dir target-dir"
  exit 1
fi

target="/Users/ian/Pictures/Organized"
if [ "$2" != "" ]; then
  target=$2
fi

find -E $1 -type f -regex '.*/[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}\.[0-9]{2}\.[0-9]{2}.*' |
while read filename
do
  #sdir=$(dirname "$filename")
  file=$(basename "$filename")
  if [[ -f "$filename" && $file =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]];
  then
    year=${file:0:4}
    month=${file:5:2}
    dir="${target}/$year/${year}-${month}"
    mkdir -p "$dir"
    if [ -d "$dir" ];
    then
      if [ -f "$dir/$file" ];
      then
        diff "$filename" "$dir/$file"
        if [ $? == 0 ];
        then
          echo "File already exists, matches this file"
          rm "$filename"
        else
          echo "$dir/$file modified version exists, not copying"
        fi
      else
        echo mv "$filename" "$dir"
        mv "$filename" "$dir"
      fi
    fi
  fi
done
