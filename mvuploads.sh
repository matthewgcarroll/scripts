#!/bin/bash
# This script is to move files imported by DropBox from Camera Uploads to a more organized home
# If you have a bunch of files from other sources, use exiftool to rename them to the
# appropriate format - we don't use exiftool to do the final mv, because it tends to make dupes
# http://www.sno.phy.queensu.ca/~phil/exiftool/filename.html
# exiftool -r -d "tmp2/%Y/%Y%m/%Y-%m-%d %H.%M.%S.%%e" "-filename<CreateDate" tmp or
# exiftool -r -d "tmp2/%Y-%m-%d %H.%M.%S.%%e" "-filename<CreateDate" tmp

if [ "$1" = "" ]; then
  echo "Usage: mvuploads.sh dir-containing-files"
  exit 1
fi
cd "$1"
for file in *
do
  if [[ -f "$file" && $file =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]];
  then
    echo $file
    year=${file:0:4}
    month=${file:5:2}
    if [[ ! $year =~ ^[0-9]{4}$ ]];
    then
      echo "year error!" $year
      continue
    fi
    if [[ ! $month =~ ^[0-9]{2}$ ]];
    then
      echo "month error!:$month:"
      continue
    fi
    dir="$HOME/OneDrive/Pictures/$year/${year}${month}"
    mkdir -p "$dir"
    if [ -d "$dir" ];
    then
      if [ -f "$dir/$file" ];
      then
        diff "$file" "$dir/$file"
        if [ $? == 0 ];
        then
          echo "File already exists, matches this file"
          rm "$file"
        else
          echo "$dir/$file modified version exists, not copying"
        fi
      else
        mv "$file" $dir
      fi
    fi
  fi
done
