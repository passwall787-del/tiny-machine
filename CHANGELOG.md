# Changelog

## Unreleased / P1

### Added

- P1 GameState：EDITING / RUNNING / PAUSED / SUCCESS。
- 目标区域终端通关机制。
- Spring 弹簧原型。
- Switch 开关。
- Gear 齿轮原型。
- Rope 绳子原型。
- Scissors 剪刀。
- Balloon 气球。
- P1 Level 002 机关演示关卡。
- 关卡选择。
- P1 Android CI 构建目标。

### Changed

- 顶部工具栏重新布局。
- 继续使用高对比度按钮样式。
- 通关后冻结所有动态物体并停止机关逻辑。
- Reset 现在恢复 P1 机关状态。
- 目标对象进入 Target 后立即结束当前模拟，不再继续推进物理状态。

### Fixed

- 修复目标进入后物理状态可能继续变化的问题。
- 修复编辑/运行状态之间组件交互边界不清的问题。
- 修复 P1 构建过程中不同 PhysicsBody2D 类型混用导致的脚本/碰撞体初始化问题。

### P1 Build 19

- GitHub Actions Run：`33157898382`
- Commit：`cf18a82d0b68095da0b0ab885088a5ff17e70add`
- Android ARM64 APK：`TinyMachineP1.apk`
- APK size：28,267,151 bytes
- SHA-256：`29f213a71887fc624857048d394585dd7acf0e254ea29fcbef3d98366ba8e942`
- Release tag：`tiny-machine-p1-19`
- CI：success
- 真机验收：待人工测试

### Known limitations

- Rope 还不是完整物理约束。
- Gear 还是原型级机械传递。
- 关卡数据仍硬编码在 `main.gd`。
- P1 仍需要 Android 真机回归和关卡可解性验证矩阵。

## P0

### Added

- 小球、木板、斜坡、目标区。
- 2D 物理。
- Android 触摸拖动。
- 开始/暂停/继续/重置。
- Level 001。

### Fixed

- Level 001 斜坡方向和可解性。
- UI 按钮对比度。
