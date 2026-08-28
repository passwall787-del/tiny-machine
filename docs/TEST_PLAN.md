# 测试计划

## 自动化 CI
每次代码/关卡数据变更：
1. Godot headless import。
2. 执行 `tests/test_runner.gd`。
3. 执行 `tests/smoke_runner.gd`，实例化主场景并验证运行时初始化、首关 Ball/Goal、RUNNING→SUCCESS 终端状态。
4. 通过后导出 Android ARM64 APK。
5. 校验 APK 非空并记录 SHA-256。
6. 发布 GitHub prerelease。

## 数据测试覆盖
- levels.json 可解析。
- 官方关卡 ≥30；当前 32。
- ID 唯一。
- 组件类型合法。
- 目标和组件坐标在边界内。
- 每关恰好一个 Ball。
- LevelData JSON 往返。
- Validator 能拒绝非法关卡。

## 运行时 Smoke 覆盖
- main.tscn 可实例化。
- LevelRuntime 初始化。
- 首关存在 Ball 和 Goal。
- 初始状态 EDITING。
- `toggle_run()` 能进入 RUNNING。
- Goal 回调能立即进入 SUCCESS。

## Android 真机回归
### P0/P1 核心
- 触摸拖动。
- 目标进入立即停止。
- 重置后速度清零。
- 暂停/继续。

### P2 编辑器
- 删除。
- 旋转。
- 多选拖动。
- 撤销/重做。
- 网格吸附开关。
- 保存/加载。
- 非法关卡不能运行。

### P3 内容
- 32 关可以切换。
- 教程 1~5 显示。
- 成功动画。
- 掉出场地失败。
- 18 秒超时失败。
- 音乐可关闭。
- 成功/失败提示音。

## 回归原则
任何涉及 GameState、目标碰撞、RigidBody2D、组件触发、LevelData 或关卡布局的提交，都必须重新跑自动化测试和 Android 构建；真机发现问题后先修代码/数据，再重新 CI，再生成 APK。
