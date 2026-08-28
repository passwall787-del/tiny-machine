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

### Fixed

- 修复目标进入后物理状态可能继续变化的问题。
- 修复编辑/运行状态之间组件交互边界不清的问题。

### Known limitations

- Rope 还不是完整物理约束。
- Gear 还是原型级机械传递。
- 关卡数据仍硬编码在 `main.gd`。

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
