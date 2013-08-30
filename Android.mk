LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_PREBUILT_EXECUTABLES := bin/xfstk-stitcher
include $(BUILD_HOST_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := ifcl
LOCAL_IS_HOST_MODULE := true
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_UNINSTALLABLE_MODULE := true
LOCAL_MODULE_SUFFIX := .zip
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE):
	$(hide) mkdir -p $(dir $@)
	$(hide) mkdir -p $(HOST_OUT_EXECUTABLES)
	$(hide) cp $(LOCAL_PATH)/bin/portable-fcl/$(notdir $@) $(dir $@)
	$(hide) unzip -o $@ -d $(HOST_OUT_EXECUTABLES)
include $(BUILD_HOST_PREBUILT)