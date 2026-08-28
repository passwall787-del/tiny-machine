# Android 构建

## CI
使用 Godot 4.7.2 CI Docker 镜像，在 Ubuntu 24.04 runner 上执行：

1. import project
2. headless script/data tests
3. runtime smoke
4. 32-level default playability regression
5. Android ARM64 debug APK export
6. APK signature verification
7. SHA-256
8. GitHub prerelease

## 当前成功构建
- Release：`tiny-machine-p3-37`
- APK：`TinyMachineP3.apk`
- 架构：ARM64 / arm64-v8a
- SHA-256：`9bbb8931ab7d6ac2b8fa275ba6331fe8621ea9e40dfae6545c402a2aef529334`

## 临时下载
本次 CI 临时链接：`https://litter.catbox.moe/ojb0tj.apk`。它只适合短期测试；GitHub Release asset 是公开稳定入口。

## 真机
当前为 debug APK，适合测试。正式发布前仍需正式签名 AAB、图标/权限/商店元数据和渠道验收。

## 已知 CI 环境警告
CI 镜像存在 fontconfig 缺失、Android SDK build-tools 自动回退到 33.0.2、ADB daemon 不可用等环境警告；本次 APK 仍完成签名验证并成功导出。这些不代表 Android 真机运行异常。
