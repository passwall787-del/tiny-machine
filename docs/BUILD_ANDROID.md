# Android 构建

## CI
使用 Godot 4.7.2 CI Docker 镜像，在 Ubuntu 24.04 runner 上执行。

顺序：
1. import project
2. headless automated tests
3. `godot --headless --export-debug "Android" build/android/TinyMachineP3.apk`
4. APK 非空检查
5. SHA-256
6. GitHub prerelease

## 输出
Release 命名：`tiny-machine-p3-<run_number>`
APK：`TinyMachineP3.apk`

## 真机
当前导出为 Android ARM64 debug APK，适合测试。正式发布前仍需正式签名 AAB、权限/图标检查和渠道验收。

## 临时下载
CI 会尝试上传一次性 Litterbox 链接；如果临时上传失败，GitHub Release asset 作为公开备用下载地址。
