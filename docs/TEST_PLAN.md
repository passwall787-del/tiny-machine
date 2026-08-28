# 测试计划

## 1. P0 回归

### Level 001

- [ ] 启动。
- [ ] 编辑。
- [ ] 开始。
- [ ] 小球沿斜坡运行。
- [ ] 进入目标。
- [ ] 成功立即终止。
- [ ] Reset。

## 2. P1 机关

### Spring

- [ ] 可添加。
- [ ] 可拖动。
- [ ] 运行时触发。
- [ ] 每次运行只触发一次。
- [ ] Reset 后可以再次触发。

### Switch

- [ ] 可添加。
- [ ] 小球靠近后 ON。
- [ ] 激活 Gear/Spring。
- [ ] Reset 后 OFF。

### Gear

- [ ] 可添加。
- [ ] 激活后旋转。
- [ ] 小球靠近后产生一次切向冲量。
- [ ] 成功/Reset 后停止并恢复。

### Rope / Scissors

- [ ] Rope 可添加和移动。
- [ ] 初始状态完整。
- [ ] Scissors 靠近后剪断。
- [ ] 剪断状态视觉明确。
- [ ] Reset 恢复完整。

### Balloon

- [ ] 可添加。
- [ ] Start 后上浮。
- [ ] Pause 后停止。
- [ ] Resume 后继续。
- [ ] Reset 回到初始位置。

## 3. GameState

```text
EDITING → RUNNING
RUNNING → PAUSED
PAUSED → RUNNING
RUNNING → SUCCESS
SUCCESS → RESET → EDITING
```

每条路径都需要验证。

## 4. Goal Terminal Test

这是 P1 的重点回归：

- [ ] Ball 进入 Target 后状态立即为 SUCCESS。
- [ ] Ball 速度被清零。
- [ ] Balloon 停止。
- [ ] Gear 停止。
- [ ] Spring 不再触发。
- [ ] Scissors 不再剪切。
- [ ] 添加组件按钮禁用。
- [ ] 关卡选择禁用。
- [ ] Reset 后恢复 EDITING。

## 5. Android

至少验证：

- [ ] Android ARM64 安装。
- [ ] 触摸拖动 Ball。
- [ ] 触摸拖动 Board。
- [ ] 触摸拖动 Slope。
- [ ] 触摸拖动 P1 组件。
- [ ] Start / Pause / Resume / Reset。
- [ ] Level selector。
- [ ] 小屏幕文字可读。
- [ ] 按钮对比度足够。
- [ ] 成功状态不会继续运动。

## 6. 性能

目标设备上观察：

- 60 FPS 优先。
- 无持续发热异常。
- 无明显输入延迟。
- 无物理抖动失控。

## 7. 构建

CI 必须：

- 成功导入 Godot 项目。
- 成功导出 ARM64 APK。
- APK 非空。
- SHA-256 可记录。
- Release asset 可下载。
