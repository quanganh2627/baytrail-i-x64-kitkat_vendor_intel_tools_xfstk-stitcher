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
    echo "$0 --input <OS image> --output <Stitched OS image output> --xml <XML filename> --plt_type <Product name>"
    echo " -p, --plt_type  Platform type:  MSTN, MFDA0, MFDB0, MFDC0, MFDD0, CLVA0, MRFLDA0"

    return 0
}

TEMP=`getopt \
         -o hi:o:x:p: \
         --long help,input:,output:,xml:,plt_type: \
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
        -p|--plt_type) PLT_TYPE=$2; shift 2;;
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
echo PLT_TYPE=$PLT_TYPE

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
sed -r -i -e 's;PlatformType\s*=.*$;PlatformType = '"${PLT_TYPE}"';g' $TMP_DIR/$OS_CFG
sed -r -i -e 's;platformXML\s*=.*$;platformXML = '"$TMP_DIR/$XML"';g' $TMP_DIR/$OS_CFG

# call stitching tool
# $TMP_DIR/$XML is provided 2 times : platformXML arg in ConfigFile_os.txt and with -k option
# -k option is required for MFLDC0 platform type but not MRFLDA0 platform type
# platformXML arg in ConfigFile_os.txt is required for MRFLDA0 platform type
if [ "$PLT_TYPE" == "MRFLDA0" ]; then
    XFSTK_ADDITIONAL_ARG=""
else
    XFSTK_ADDITIONAL_ARG="-k $TMP_DIR/$XML"
fi
./bin/xfstk-stitcher -c $TMP_DIR/$OS_CFG $XFSTK_ADDITIONAL_ARG
[ $? -ne 0 ] && _EXIT=1
rm -rf $TMP_DIR

cd $TOP
exit $_EXIT
