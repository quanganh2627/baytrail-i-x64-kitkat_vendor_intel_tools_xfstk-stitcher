LOCAL_PATH := $(call my-dir)
STITCHER_EXT_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_PREBUILT_EXECUTABLES := bin/xfstk-stitcher
include $(BUILD_HOST_PREBUILT)

include $(CLEAR_VARS)
LOCAL_PREBUILT_EXECUTABLES := bin/ifcl/ifcl
LOCAL_REQUIRED_MODULES := bin/ifcl/libxfstk-ifcl.a
include $(BUILD_HOST_PREBUILT)

include $(CLEAR_VARS)
LOCAL_PREBUILT_LIBS := bin/ifcl/libxfstk-ifcl.a
include $(BUILD_HOST_PREBUILT)
