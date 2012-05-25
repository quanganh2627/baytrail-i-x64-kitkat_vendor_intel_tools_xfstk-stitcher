#!/bin/bash -x

set -e

function abs_path()
{
    rel_path=`dirname $1`;
    cd $rel_path;
    abs_path=`pwd`
    cd - 2>&1 > /dev/null
    echo $abs_path;

    return 0
}

function usage()
{
    echo "$0 --input <OS image> --output <Stitched OS image output> --xml <XML filename>"

    return 0
}

TEMP=`getopt \
         -o hi:o:x: \
         --long help,input:,output:,xml: \
         -n '$0' \
         --  "$@"`

eval set -- "$TEMP"
while true ; do
    echo "+++++ case $1 +++++"
    case "$1" in
        -i|--input) OS="$2"; shift 2;;
        -h|--help) usage; exit 0; shift;;
        -o|--output) OSUSB="$2"; shift 2;;
        -x|--xml) XML="$2"; shift 2;;
        --) shift ; break ;;
    esac
done

_EXIT=0

[ -z $OS ] && usage >&2 && exit 1;
[ -z $OSUSB ] && usage >&2 && exit 1;
[ -z $XML ] && usage >&2 && exit 1;

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
[ $? -ne 0 ] && _EXIT=1
rm -rf $TMP_DIR

cd $TOP
exit $_EXIT
