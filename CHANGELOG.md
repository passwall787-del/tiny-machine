# CHANGELOG

## P3
- 新增 32 个官方关卡数据。
- 新增教程 1~5 关和 1~8 星难度曲线。
- 新增 Magnet / Bomb。
- 新增成功/失败状态和动画反馈。
- 新增程序化音效、轻量 BGM 和音乐开关。
- 新增 P2 关卡编辑器：删除、旋转、多选、撤销、重做、网格吸附、保存/加载、验证。
- 新增 LevelData / LevelRuntime / ComponentFactory / LevelValidator / MachineComponent / AudioManager。
- 新增 headless 自动化测试并接入 Android CI。

## P2
- 关卡从硬编码布局迁移到 `levels.json` + `LevelData`。
- 建立编辑操作历史栈。

## P1
- 目标区进入成为终端事件。
- Spring / Switch / Gear / Rope / Scissors / Balloon 原型。
