# Android 构建与发布

## 1. 当前构建目标

- Engine: Godot 4.7.2 CI
- Platform: Android
- Architecture: `arm64-v8a`
- Version: `0.1.0`
- Package: `com.passwall.tinymachine`
- Current build: Debug/test APK

## 2. CI 构建

仓库工作流：

```text
.github/workflows/android-p0.yml
```

流程：

```text
push main
  ↓
GitHub Actions
  ↓
Ubuntu runner
  ↓
Godot CI 4.7.2
  ↓
Import project
  ↓
Export Android
  ↓
检查 APK 非空
  ↓
输出 SHA-256
  ↓
GitHub Release
```

## 3. 本地 Android 环境

Godot 官方当前 Android 导出文档建议使用 OpenJDK 17；Android SDK 需要配置到 Godot Editor Settings。不同 Godot 版本的 SDK/NDK 版本要求可能变化，因此实际开发时以当前 Godot 版本文档为准。

参考：

https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html

## 4. 本地导出

在 Godot 中：

1. 打开项目。
2. 打开 Project → Export。
3. 选择 Android。
4. 确认 ARM64 开启。
5. 选择 Debug 导出。
6. 输出 `build/android/TinyMachineP0.apk`。

命令行示例：

```bash
godot --headless --editor --import --quit
godot --headless --export-debug "Android" build/android/TinyMachineP0.apk
```

## 5. APK 校验

构建后：

```bash
sha256sum build/android/TinyMachineP0.apk
ls -lh build/android/TinyMachineP0.apk
```

不要只判断 Actions 成功；必须确认 APK 文件存在且大小大于 0。

## 6. Debug 与 Release

P0 只使用 Debug/test APK。

正式发布前必须：

- 创建正式 keystore。
- 安全保存 keystore 和密码。
- 不把 keystore 提交到 Git。
- 配置 Release signing。
- 升级版本号和 version code。
- 生成 AAB。
- 在真实设备上测试升级、安装和卸载。

## 7. 发布版本

正式 Google Play 发布需要 AAB，而不是仅提供 APK。Godot 官方 Android 导出文档也要求正式商店上传使用非 Debug 签名。

## 8. 版本规则

建议：

```text
0.x.y
```

其中：

- `x`：阶段版本，例如 P0/P1。
- `y`：修复/迭代次数。

进入正式发行后再采用：

```text
MAJOR.MINOR.PATCH
```

## 9. APK 发布规则

每个测试 APK 必须记录：

- Git commit SHA
- 构建时间
- Godot 版本
- Android 架构
- version name
- version code
- SHA-256
- 已知问题

## 10. 安全

禁止：

- 把正式 keystore 提交到仓库。
- 在源码中写密码。
- 把生产 API key 写进 APK 构建脚本。
- 使用 Debug keystore 作为正式商店签名。
