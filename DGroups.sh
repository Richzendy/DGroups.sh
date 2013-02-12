#!/bin/bash
# Script creado por Edwind Contreras < richzendy@gmail.com > 
# Licencia GNU GPL V3
# Find updates in https://github.com/Richzendy/DGroups.sh

DPATH='/etc/dansguardian'
DFILES='bannedextensionlist bannedmimetypelist bannedphraselist bannedregexpheaderlist bannedregexpurllist bannedsitelist bannedurllist contentregexplist exceptionextensionlist exceptionfilesitelist  exceptionfileurllist exceptionmimetypelist exceptionphraselist exceptionregexpurllist exceptionsitelist exceptionurllist greysitelist greyurllist urlregexplist weightedphraselist'
DGROUPS=$(grep 'filtergroups =' /etc/dansguardian/dansguardian.conf | cut -f 2 -d '=' | sed 's/ //')
NGROUP=`echo $[$DGROUPS + 1]`
UNO=$1 
DOS=$2

create () {

if [ -z $DOS ] ; then
echo 'ERROR: Group Name not found how option'
echo ''
help
fi

echo "Verifing files, please wait..."

for DFILE in $DFILES ; do
if [ ! -f $DPATH/lists/$DFILE ] ; then
echo "ERROR: file $DPATH/$DFILE  don't exist, must be created!"
exit 1
fi
echo "$DPATH/lists/$DFILE exist!"
done

if [ ! -f $DPATH/dansguardianf1.conf ] ; then
echo "ERROR: file $DPATH/dansguardianf1.conf  don't exist, must be created!"
exit 1
fi
echo "$DPATH/dansguardianf1.conf exist!"

echo "Creating group: $DOS, please wait..."

cp $DPATH/dansguardianf1.conf $DPATH/dansguardianf$NGROUP.conf
sed -i "s/#groupname = ''/groupname = '$DOS'/" $DPATH/dansguardianf$NGROUP.conf

for DFILE in $DFILES ; do
cp $DPATH/lists/$DFILE $DPATH/lists/$DFILE.$DOS 
done

echo "Group $DOS created,  edit files with .$DOS extension in $DPATH/lists/$DFILE to personalizate your new group."
echo ''
echo "When you finish your senttings in blacklists, edit $DPATH/dansguardian.conf and change the line:"
echo "filtergroups = $DGROUPS"
echo "by: filtergroups = $NGROUP"
echo 'and restart dansguardian :-)'
}

delete () {

MGROUP=`echo $[$DGROUPS - 1]`
DFILTER=`grep -ER $DOS $DPATH/dansguardianf*.conf | cut -f 1 -d ':'`

if [ -z $DOS ] ; then
echo 'ERROR: Group Name not found how option'
echo ''
help
fi

if [ -z $DFILTER ] ; then
echo "ERROR: Group Name not found, check and remove manually $DPATH/lists/*.$DOS files if exists!"
echo ''
exit 1
fi

echo "Removing Group $DOS..."

rm -f $DPATH/lists/*.$DOS
rm -f $DFILTER

echo "Group $DOS removed succesfull,  edit $DPATH/dansguardian.conf and change the line:"
echo "filtergroups = $DGROUPS"
echo "by: filtergroups = $MGROUP"
echo 'and restart dansguardian :-)'

}

list () {

DGROUPS_CREATED=`ls $DPATH/lists/*.* | cut -f 2 -d '.' | sort -u`

echo 'Groups:'
echo $DGROUPS_CREATED

}

help () {
    echo "Usage: $0 {create|delete|list} [options...]"
    echo ""
    echo "Examples:"
    echo "$0 create managers"
    echo "       To create the managers group"
    echo "$0 delete managers"
    echo "       To delete the managers group"
    echo "$0 list"
    echo "       To list all created groups" 
    exit 1
}

case "$1" in
  create)
	create
        ;;
  delete)
	delete
        ;;
  list)
	list
        ;;

  *)
        help
        ;;
esac

exit 0
