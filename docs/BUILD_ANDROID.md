# Android 构建与发布

## 1. 当前构建目标

- Engine: Godot 4.7.2 CI
- Platform: Android
- Architecture: `arm64-v8a`
- Package: `com.passwall.tinymachine`
- Current build: P1 Debug/test APK

## 2. CI 构建

仓库工作流当前文件：

```text
.github/workflows/android-p0.yml
```

文件名暂时保留历史名称，但 workflow 已经切换为 **Tiny Machine P1 Android**。

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
Export Android ARM64
  ↓
检查 APK 非空
  ↓
输出 SHA-256
  ↓
GitHub Release
```

Release tag：

```text
tiny-machine-p1-<run_number>
```

APK 文件名：

```text
TinyMachineP1.apk
```

## 3. 本地 Android 环境

建议使用 OpenJDK 17、Android SDK 和匹配 Godot 4.7.2 的 Android export templates。不同 Godot 版本的 SDK/NDK 要求可能变化，实际配置以当前 Godot 版本文档为准。

## 4. 本地导出

在 Godot 中：

1. 打开项目。
2. Project → Export。
3. 选择 Android。
4. 确认 ARM64 开启。
5. 选择 Debug 导出。
6. 输出 `build/android/TinyMachineP1.apk`。

命令行示例：

```bash
godot --headless --editor --import --quit
godot --headless --export-debug "Android" build/android/TinyMachineP1.apk
```

## 5. APK 校验

```bash
sha256sum build/android/TinyMachineP1.apk
ls -lh build/android/TinyMachineP1.apk
```

不要只判断 Actions 成功；必须确认 APK 文件存在且大小大于 0。

## 6. P1 发布规则

每个测试 APK 必须记录：

- Git commit SHA
- 构建时间
- Godot 版本
- Android 架构
- version name
- version code
- SHA-256
- 已知问题

## 7. Debug 与 Release

P1 继续使用 Debug/test APK。

正式发布前必须：

- 创建正式 keystore。
- 安全保存 keystore 和密码。
- 不把 keystore 提交到 Git。
- 配置 Release signing。
- 升级版本号和 version code。
- 生成 AAB。
- 在真实设备上测试安装、升级和卸载。

## 8. 正式商店

正式 Google Play 发布使用 AAB，而不是仅提供 APK。

## 9. 安全

禁止：

- 把正式 keystore 提交到仓库。
- 在源码中写密码。
- 把生产 API key 写进 APK 构建脚本。
- 使用 Debug keystore 作为正式商店签名。
