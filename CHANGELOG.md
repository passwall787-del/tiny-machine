# CHANGELOG

## P3
- 新增 32 个官方关卡数据。
- 新增教程 1~5 关和 1~8 星难度曲线。
- 新增 Magnet / Bomb。
- 新增成功/失败状态和动画反馈。
- 新增程序化音效、轻量 BGM 和音乐开关。
- 新增 P2 关卡编辑器：删除、旋转、多选、撤销、重做、网格吸附、保存/加载、验证。
- 新增 LevelData / LevelRuntime / ComponentFactory / LevelValidator / MachineComponent / AudioManager。
- 新增 headless 自动化测试、主场景 runtime smoke 和 32 关默认可解性回归。
- Android CI 只有在全部测试和 APK 导出成功后才创建 Release。
- 增加项目 SVG 图标。

### 回归修复
- 修复组件与 Godot 原生物理类型的静态转换问题。
- 修复 typed `Array[Dictionary]` 与普通 `Array` 的赋值问题。
- 修复工具栏按钮重叠。
- 修复物理查询 flush 时直接冻结刚通关物体的问题。
- 增加跨帧目标轨迹检测，避免高速小球穿过目标区域而漏判。
- 调整坡面碰撞与低摩擦材质，使默认路径稳定。
- 调整机关展示位置，避免默认路径被 Magnet/Bomb 意外干扰。
- 修复 CI 测试失败仍可能发布 Release 的问题。
- 修复 playability runner 释放场景后错误显示 0 关的问题。
- 修复目标数据文件与运行时默认目标坐标不一致的问题。

### Run 37
- 32/32 官方默认布局通过实际 headless 物理回归。
- Android ARM64 APK 导出、签名验证通过。
- SHA-256：`9bbb8931ab7d6ac2b8fa275ba6331fe8621ea9e40dfae6545c402a2aef529334`

## P2
- 关卡从硬编码布局迁移到 `levels.json` + `LevelData`。
- 建立编辑操作历史栈。

## P1
- 目标区进入成为终端事件。
- Spring / Switch / Gear / Rope / Scissors / Balloon 原型。
