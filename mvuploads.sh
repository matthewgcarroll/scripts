#!/bin/bash
cd "~/Dropbox/Camera Uploads"
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
    dir="~OneDrive/Archive/$year/${year}${month}"
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
