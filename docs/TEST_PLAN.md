# 测试计划

## 自动化 CI
每次代码/关卡数据变更：
1. Godot headless import。
2. `tests/test_runner.gd`：脚本加载、32 关数据、ID、组件、目标边界、序列化、Validator 负例。
3. `tests/smoke_runner.gd`：主场景实例化、LevelRuntime、Ball/Goal、EDITING→RUNNING→SUCCESS。
4. `tests/playability_runner.gd`：用加速后的 headless 物理回归逐关运行 32 个官方默认布局，检查是否达到 SUCCESS。
5. 通过后导出 Android ARM64 APK。
6. 校验 APK 非空、SHA-256。
7. 仅在完整 job 成功后发布 GitHub prerelease。

## Android 真机回归
### 核心
- 触摸拖动。
- 目标进入立即停止。
- 重置后速度清零。
- 暂停/继续。

### P2 编辑器
- 删除、旋转、多选。
- 撤销/重做。
- 网格吸附开关。
- 保存/加载。
- 非法关卡不能运行。

### P3 内容
- 32 关切换。
- 教程 1~5。
- 难度 1~8 星。
- 成功动画。
- 掉出场地失败。
- 18 秒超时失败。
- 音乐开关、成功/失败提示音。
- 磁铁/炸弹不应无故阻断展示关卡默认路径。

## 回归原则
发现问题后：记录 → 修复代码或关卡数据 → CI 自动化 → APK → 真机复测。未通过自动化或真机回归的版本不作为稳定测试版。
