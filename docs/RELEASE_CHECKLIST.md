# Release Checklist

## P1 功能

- [ ] Level 001 稳定可解。
- [ ] Level 002 稳定可解。
- [ ] Spring 正常。
- [ ] Switch 正常。
- [ ] Gear 正常。
- [ ] Rope / Scissors 正常。
- [ ] Balloon 正常。
- [ ] Target 进入立即终止模拟。
- [ ] SUCCESS 后不能继续编辑或运行。
- [ ] Reset 无残留状态。

## UI

- [ ] 主按钮清晰可见。
- [ ] 组件按钮清晰可见。
- [ ] 触摸区域足够大。
- [ ] 文本无截断。
- [ ] 不同屏幕比例没有关键 UI 遮挡。
- [ ] SUCCESS 状态清晰。

## 物理

- [ ] 默认解连续成功。
- [ ] 无明显穿透。
- [ ] 无明显卡死。
- [ ] Pause / Resume 正常。
- [ ] Reset 正常。
- [ ] 成功后物理停止。
- [ ] 不依赖设备帧率。

## Android

- [ ] ARM64 安装测试。
- [ ] 启动测试。
- [ ] 触摸编辑测试。
- [ ] 返回/切后台测试。
- [ ] 屏幕比例测试。
- [ ] 重新安装测试。

## Build

- [ ] GitHub Actions 成功。
- [ ] APK 文件存在。
- [ ] APK 大小合理。
- [ ] SHA-256 已记录。
- [ ] version name 正确。
- [ ] version code 正确。

## Release signing

正式版：

- [ ] 使用正式 keystore。
- [ ] keystore 不在仓库。
- [ ] 密码来自 GitHub Secrets/安全存储。
- [ ] Debug signing 已关闭。
- [ ] AAB 构建成功。

## 文档

- [ ] README 更新。
- [ ] CHANGELOG 更新。
- [ ] ROADMAP 更新。
- [ ] PROJECT_STATUS 更新。
- [ ] GAMEPLAY 更新。
- [ ] PHYSICS 更新。
- [ ] COMPONENTS 更新。
- [ ] LEVEL_DESIGN 更新。
- [ ] Level 文档更新。
- [ ] TEST_PLAN 更新。
