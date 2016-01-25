#!/bin/ksh
usage="Usage: info_bkup.sh directory account\nE.g: info_bkup /info BOTW"
log=/home/dsiroot/bkup/bkup.log

echo "Starting [$*] on `date`" >> $log

if [ "x$1" = "x" ]; then
        echo $usage
        exit 1
fi

if [ ! -d $1 ]; then
        echo $usage
        exit 1
fi

if [ "x$2" = "x" ]; then
        echo $usage
        exit 1
fi

# First compress and tar the account
cd $1
echo `date` /opt/freeware/bin/tar zcf /info_nightly/$2_nightly.tar.gz >>$log
/opt/freeware/bin/tar zcf /info_nightly/$2_nightly.tar.gz $2 >>$log 2>&1

echo "Finished [$*] on `date`" >>$log
