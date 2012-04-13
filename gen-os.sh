#!/bin/bash

abs_path()
{
        rel_path=`dirname $1`;
        cd $rel_path;
        abs_path=`pwd`
        cd - 2>&1 > /dev/null
        echo $abs_path;
}

usage()
{
        echo "$0 --input <OS image> --output <Stitched OS image output> --xml <XML filename>"
        exit 1
}

TEMP=`getopt \
         -o i:o:x: \
         --long input:,output:,xml: \
         -n '$0' \
         --  "$@"`

eval set -- "$TEMP"
while true ; do
    echo "+++++ case $1 +++++"
    case "$1" in
        --input) OS="$2"; shift 2;;
        --output) OSUSB="$2"; shift 2;;
        --xml) XML="$2"; shift 2;;
        --) shift ; break ;;
    esac
done

_EXIT=0

[ -z $OS ] && usage;
[ -z $OSUSB ] && usage;
[ -z $XML ] && usage;

echo OS=$OS
echo OSUSB=$OSUSB
echo XML=$XML

TOP=$PWD

if [ -z $ANDROID_PRODUCT_OUT ]; then
    WORKDIR=${TOP}
else
    WORKDIR=${ANDROID_PRODUCT_OUT}
fi
fstk_path=$(abs_path $0)
cd $fstk_path

TMP_DIR=$(mktemp -d "${WORKDIR}"/tmp.XXXXXXXX)
OS_CFG=OS_Stitching_Config.txt
cp share/xfstk-stitcher/$OS_CFG $TMP_DIR/$OS_CFG
cp share/xfstk-stitcher/$XML $TMP_DIR/$XML

# update input and output file names in xfstk-stitcher XML and ConfigFile
sed -r -i -e 's;<image_filepath>.*</image_filepath>;<image_filepath>'"${OS}"'</image_filepath>;g' $TMP_DIR/$XML
sed -r -i -e 's;ImageName\s*=.*$;ImageName = '"${OSUSB}"';g' $TMP_DIR/$OS_CFG

# call stitching tool
./bin/xfstk-stitcher -k $TMP_DIR/$XML -c $TMP_DIR/$OS_CFG
if [ $? -ne 0 ]
then
    _EXIT=1
fi
rm -rf $TMP_DIR

cd $TOP
exit $_EXIT
