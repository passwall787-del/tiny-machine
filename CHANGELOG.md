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
- GitHub Release 作为唯一公共 APK 分发入口，移除不稳定的临时 Litterbox 上传。

### 回归修复
- 修复组件与 Godot 原生物理类型的静态转换问题。
- 修复 typed `Array[Dictionary]` 与普通 `Array` 的赋值问题。
- 修复工具栏按钮重叠。
- 修复物理查询 flush 时直接冻结刚通关物体的问题。
- 增加跨帧目标轨迹检测，避免高速小球穿过目标区域而漏判。
- 调整坡面碰撞与低摩擦材质，使默认路径稳定。
- 调整机关展示位置，避免默认路径被 Magnet/Bomb 意外干扰。
- 修复 CI 测试失败仍可能发布 Release 的问题。
- 修复 playability runner 初始化过早导致的假阳性；现在硬性要求加载 32 个官方关卡后逐关运行。
- 修复测试环境 timeout 与 `Engine.time_scale` 叠加造成的误报失败。
- 修复 playability runner 释放场景后错误显示 0 关的问题。
- 修复 playability runner 日志修复中的 GDScript 参数/类型解析错误。
- 修复目标数据文件与运行时默认目标坐标不一致的问题。

### Run 37
- 32/32 官方默认布局通过实际 headless 物理回归。
- Android ARM64 APK 导出、签名验证通过。
- SHA-256：`9bbb8931ab7d6ac2b8fa275ba6331fe8621ea9e40dfae6545c402a2aef529334`

### Run 38
- 再次通过 32/32 官方默认布局实际 headless 物理回归。
- Android ARM64 APK 导出、签名验证通过。
- SHA-256：`caa81c9d375536393ca593011075f149087f0194d2feb1bec704f8494b69b0c0`
- 临时 Litterbox 上传出现 HTTP 500，但该步骤为可选失败，GitHub Release 正常生成。

### Run 39
- playability runner 日志修复首次提交触发 GDScript 参数/类型解析错误，未发布 APK。
- 随后立即修复并由 Run 40 回归。

### Run 40
- 32/32 官方默认布局实际 headless 物理回归通过。
- 自动化脚本、数据、runtime smoke 全部通过。
- Android ARM64 APK 导出和签名验证通过。
- SHA-256：`b23c41f649bfc89a3e9bc91c64ab360d2a016ff9fd98064b24150814ac4ea0d0`
- GitHub Release：`tiny-machine-p3-40`。

### Run 41
- 移除临时 Litterbox 分发步骤，降低 CI 外部依赖。
- 32/32 官方默认布局实际 headless 物理回归通过。
- 自动化脚本、数据、runtime smoke 全部通过。
- Android ARM64 APK 导出和签名验证通过。
- SHA-256：`14604768874c1bd87ea87db8784b64024bbd7a48394fbb351eada1963e0f38ef`
- GitHub Release：`tiny-machine-p3-41`。

## P2
- 关卡从硬编码布局迁移到 `levels.json` + `LevelData`。
- 建立编辑操作历史栈。

## P1
- 目标区进入成为终端事件。
- Spring / Switch / Gear / Rope / Scissors / Balloon 原型。
- Magnet / Bomb 原型。
