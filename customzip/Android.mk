LOCAL_PATH := $(call my-dir)
 include $(CLEAR_VARS)
     LOCAL_MODULE := magisk_prebuilt
     LOCAL_MODULE_TAGS := optional
     LOCAL_MODULE_CLASS := ETC
     LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)
     CUSTOMZIP_PATH := $(TARGET_RECOVERY_ROOT_OUT)/customzip
     MAGISK_UNOFFICIAL_VERSION := Alpha
     # 新增：先给脚本赋予可执行权限，再执行（核心修复）
     LOCAL_POST_INSTALL_CMD := \
         chmod +x $(LOCAL_PATH)/magisk_prebuilt.sh; \
         $(LOCAL_PATH)/magisk_prebuilt.sh $(CUSTOMZIP_PATH) $(MAGISK_UNOFFICIAL_VERSION);
 include $(BUILD_PHONY_PACKAGE)