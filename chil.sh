#/usr/bin/ksh
if [[ "x"$1 = "x" ]]
then
  echo "usage: chil ACCOUNTNAME"
  exit 1
fi

echo "fix permissions, ownership and endian-ness for account: $1"

cd /info

if [[ ! -d $1 ]]
then
  echo "$1 is not a directory"
  exit 1
fi

if [[ ! -f $1/VOC ]]
then
  echo "$1 is not an Infolease account"
  exit 1
fi

chmod -R 775 $1
chown -R dsiroot.info $1

# Add /usr/udXX/bin to path for the following
convdata -r $1
convidx -rs $1
convcode $1
