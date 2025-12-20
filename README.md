此为Fork版本，添加了橙狐适配

![a641d9263f25f0e578f6d814d48e0d02](_res/a641d9263f25f0e578f6d814d48e0d02.jpeg)

此fork分支会适配了两个ofrp分支版本，14.1和12.1
并应用部分来自[ymdzq的补丁](https://github.com/ymdzq/OrangeFox_Recovery)
# OFRP 小米平板6 Pro（liuqin）
基于[红米K60橙狐设备树](https://github.com/ymdzq/OFRP-device_xiaomi_mondrian)修改的TWRP设备树  
参考了sk佬[小米12S twrp设备树](https://github.com/sekaiacg/TWRP_android_device_xiaomi_mayfly)

Fork版本特色:使用我的[橙狐构建脚本](https://github.com/xccxxcys/OrangeFox-Recovery-Builder-2024)，参考来自adontoo的[小米sm8750 ofrp14.1设备树](https://github.com/adontoo/device_xiaomi_liuqin-TWRP-OF)
# 如何使用
进入[Release](https://github.com/xccxxcys/device_xiaomi_liuqin-TWRP-OF/releases)中，下载 liuqin 对应的 recovery.img或recovery.zip(解压)
已root平板可以通过爱玩机工具箱、搞机助手等app直接写入recovery分区  
也可以平板连接电脑线刷，请自备[fastboot工具](https://developer.android.google.cn/studio/releases/platform-tools?hl=zh-cn)，手动重启平板至bootloader模式（橙色fastboot字样）  
使用fastboot工具把rec镜像刷入ab两槽的rec分区，重启进入rec，命令：  
```bash
fastboot flash recovery_a recovery.img
fastboot flash recovery_b recovery.img
fastboot reboot recovery

