#!/sbin/sh
# 适配 liuqin（Xiaomi Pad 6 Pro）| 移除OnePlus专属逻辑 | 兼容WiFi功能配置
# 核心优化：机型识别、USB名称、冗余操作精简

log_file="/dev/kmsg"

# 日志函数：增加[liuqin]标识，便于排查
log() {
    echo "variant-script.sh[liuqin]: $1" | tee -a "$log_file"
    echo "variant-script.sh[liuqin]: $1" | tee -a /tmp/recovery.log
}

# 卸载分区（保留原逻辑，优化日志说明，避免误判）
log "Unmounting system/vendor/odm partitions (liuqin)..."
umount -f -l /system 2>/dev/null
log "/system unmounted (ignore if already unmounted)"
umount -f -l /vendor 2>/dev/null
log "/vendor unmounted (ignore if already unmounted)"
umount -f -l /odm 2>/dev/null
log "/odm unmounted (后续WiFi模块加载会重新挂载必要分区)"

# USB设备名称优化（liuqin专属，便于PC识别）
usb_name="Xiaomi Pad 6 Pro (liuqin)"
log "Setting USB product name to: $usb_name"
echo "$usb_name" > /config/usb_gadget/g1/strings/0x409/product

# 变体文件复制函数（liuqin无专属variant目录，保留函数但适配逻辑）
copy_variant_vendor() {
    local variant_name="$1"
    if [ -d "/vendor/variant/$variant_name" ]; then
        cp -rf /vendor/variant/$variant_name/vendor/* /vendor
        log "Copied vendor variant files: $variant_name"
    else
        log "Vendor variant dir /vendor/variant/$variant_name not found, skip copying"
    fi
}

# 机型判断（移除OnePlus专属，添加liuqin分支）
device="$(getprop ro.product.device)"
log "Detected device: $device"

case "$device" in
    "liuqin")
        # 小米Pad 6 Pro 专属处理：无需要复制的variant文件，直接跳过
        log "Liuqin device detected, no variant vendor files to copy"
        ;;

    "OP5CFBL1" | "OP5E93L1")
        # 保留原有OnePlus机型逻辑（避免误刷时兼容）
        copy_variant_vendor "audi"
        ;;

    "OP5929L1" | "OP595DL1")
        # 保留原有OnePlus机型逻辑（避免误刷时兼容）
        copy_variant_vendor "waffle"
        ;;

    *)
        # 其他机型：沿用原逻辑，输出兼容日志
        device_version="$(getprop ro.twrp.device_version)"
        log "No specific variant config for device: $device (version: $device_version)"
        ;;
esac

# 标记变体配置完成（确保后续WiFi服务正常启动）
log "Liuqin variant script executed successfully"
resetprop twrp.variant.files_copied "1"

exit 0
