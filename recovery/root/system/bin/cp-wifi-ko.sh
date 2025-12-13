#!/system/bin/sh
# 适配 liuqin（Xiaomi Pad 6 Pro）QCA6490 WiFi 芯片 | 动态分区架构 | TWRP 16.0
# 核心优化：小米fastbootd判断、分区挂载兼容、日志精细化、模块加载验证

# 1. 适配小米fastbootd模式（支持1/true两种标识，避免误判）
FASTBOOTD_PROP=$(getprop ro.twrp.fastbootd)
if [ "$FASTBOOTD_PROP" = "1" ] || [ "$FASTBOOTD_PROP" = "true" ]; then
    echo "I:cp-wifi-ko.sh: liuqin detected fastbootd (ro.twrp.fastbootd=$FASTBOOTD_PROP), exit script." >> /tmp/recovery.log
    exit 0
fi

# 2. 兼容分区已挂载场景（避免重复挂载报错，输出日志便于排查）
log_print "Mounting vendor_dlkm/system_dlkm partitions..." >> /tmp/recovery.log
mount /vendor_dlkm 2>/dev/null
if [ $? -eq 0 ]; then
    echo "I:cp-wifi-ko.sh: vendor_dlkm mounted successfully" >> /tmp/recovery.log
else
    echo "I:cp-wifi-ko.sh: vendor_dlkm already mounted or not exists" >> /tmp/recovery.log
fi

mount /system_dlkm 2>/dev/null
if [ $? -eq 0 ]; then
    echo "I:cp-wifi-ko.sh: system_dlkm mounted successfully" >> /tmp/recovery.log
else
    echo "I:cp-wifi-ko.sh: system_dlkm already mounted or not exists" >> /tmp/recovery.log
fi

# 3. 核心配置（liuqin QCA6490 专属模块列表，移除无用模块）
LOG_TAG="I:cp-wifi-ko.sh[liuqin]"
TARGET_DIR="/odm/wifi/modules"
SEARCH_DIRS="/vendor_dlkm /system_dlkm"  # liuqin 驱动分区默认路径
KO_FILES="cnss_prealloc.ko cnss_nl.ko wlan_firmware_service.ko cnss_plat_ipc_qmi_svc.ko cnss_utils.ko cnss2.ko gsim.ko rmnet_mem.ko ipam.ko rfkill.ko cfg80211.ko qca_cld3_kiwi_v2.ko"

# 日志打印函数（保留原逻辑，增加机型标识）
log_print() {
    echo "$LOG_TAG: $1" >> /tmp/recovery.log
}

# 4. 目标目录优化（确保目录存在，输出创建日志，权限严格匹配）
if [ ! -d "$TARGET_DIR" ]; then
    log_print "Target dir $TARGET_DIR not found, creating..."
    mkdir -p "$TARGET_DIR"
    if [ $? -ne 0 ]; then
        log_print "ERROR: Failed to create $TARGET_DIR (permission denied?)"
        exit 1
    fi
    chmod 0755 "$TARGET_DIR"
    log_print "Created $TARGET_DIR with permission 0755"
else
    log_print "Target dir $TARGET_DIR already exists"
    chmod 0755 "$TARGET_DIR"  # 二次确认权限，避免异常
fi

log_print "Start searching WiFi kernel modules (QCA6490)..."
log_print "Search dirs: $SEARCH_DIRS"
log_print "Modules to find: $KO_FILES"

found_count=0
copied_count=0

# 5. 模块搜索与复制（优化日志输出，便于排查缺失模块）
for ko_file in $KO_FILES; do
    file_found=0
    log_print "Processing module: $ko_file"
    for search_dir in $SEARCH_DIRS; do
        if [ -d "$search_dir" ]; then
            log_print "Searching in $search_dir..."
            # 优先搜索dlkm分区下的modules目录（liuqin驱动默认存放路径）
            file_path=$(find "$search_dir" -path "*/modules/*" -type f -name "$ko_file" 2>/dev/null | head -1)
            if [ -z "$file_path" ]; then
                # 若未找到，扩大搜索范围
                file_path=$(find "$search_dir" -type f -name "$ko_file" 2>/dev/null | head -1)
            fi
            
            if [ -n "$file_path" ] && [ -f "$file_path" ]; then
                file_found=1
                target_file="$TARGET_DIR/$ko_file"
                if [ ! -f "$target_file" ]; then
                    log_print "Copying: $file_path -> $target_file"
                    cp "$file_path" "$target_file"
                    if [ $? -eq 0 ]; then
                        chmod 0644 "$target_file"  # 模块权限标准配置
                        copied_count=$((copied_count + 1))
                        log_print "SUCCESS: Copied $ko_file"
                    else
                        log_print "ERROR: Copy $ko_file failed (cp command error)"
                    fi
                else
                    log_print "Skip: $ko_file already exists in $TARGET_DIR"
                fi
                break  # 找到后退出当前搜索目录循环
            fi
        else
            log_print "WARNING: Search dir $search_dir does not exist"
        fi
    done
    
    if [ $file_found -eq 1 ]; then
        found_count=$((found_count + 1))
        log_print "Module $ko_file found"
    else
        log_print "ERROR: Module $ko_file not found in any search dir"
    fi
done

# 6. 结果汇总日志（清晰展示加载状态）
log_print "========================================"
log_print "WiFi module copy complete:"
log_print "Total modules to find: $(echo $KO_FILES | wc -w)"
log_print "Found: $found_count | Copied: $copied_count"
log_print "========================================"

# 输出目标目录文件列表（便于验证是否复制成功）
log_print "Files in $TARGET_DIR:"
ls -la "$TARGET_DIR" 2>/dev/null | while read line; do
    log_print "$line"
done

# 7. 标记模块加载状态（与init脚本联动，便于后续服务启动判断）
resetprop twrp.cpko "true"
resetprop twrp.wifi.modules.copied "$copied_count"

log_print "Script exited successfully"
exit 0
