# 调试手册

## 构建失败
先看 GitHub Actions 的 Godot import/test/export 步骤。不要在未通过 headless test 时发布 APK。

## 运行时失败
重点检查：
- GameState 是否处于 RUNNING。
- runtime.ball 是否有效。
- Goal collision layer/mask 是否正确。
- RigidBody2D 是否被冻结。
- 组件是否被编辑器误删。

## 关卡不可解
优先修改 `levels.json` 的 pattern / slope_count 或生成参数；不要为了某一关破坏通用物理规则。

## Android 触摸
检查 viewport stretch、输入事件坐标和组件 `input_pickable`。编辑操作只在 EDITING 状态有效。

## 性能
P3 首轮限制组件规模；如果真机出现卡顿，先记录组件数、关卡编号和运行时间，再针对性优化。
