# 项目当前状态 / Handoff

## 当前阶段

**P3 首轮交付，自动化回归正在收敛，尚未把 APK 标记为最终测试版。**

P2 已完成首版关卡编辑器与数据管线；P3 已加入 32 个官方关卡、教程、难度曲线、成功/失败反馈、程序化音效和轻量 BGM。

## 最近自动化回归

- Run 23：代码级构建成功，但当时 smoke 尚未覆盖主场景运行时。
- Run 24：新增 runtime smoke 后发现真实运行时问题：`LevelData.pieces` 是 typed `Array[Dictionary]`，不能直接接收普通 `Array`；同时 workflow 在测试失败时仍错误创建空 Release。
- 已修复：`LevelRuntime.capture_level/apply_layout` 与 `main._sync_working_level` 改为逐项写入 typed array；Release 改为只在完整构建成功后发布。
- 下一次 CI 必须同时通过脚本加载检查、32 关数据测试、主场景 smoke 和 Android 导出。

## 架构

```text
main.tscn
  └─ main.gd
       ├─ LevelRuntime
       │    └─ ComponentFactory
       │         └─ MachineComponent
       ├─ LevelData / levels.json
       ├─ LevelValidator
       └─ AudioManager
```

## P2

删除、旋转、多选、撤销、重做、网格吸附、保存/加载、本机关卡验证均已接入运行时。

## P3

- 官方关卡：32
- 教程：1~5
- 难度：1~8 星
- Magnet / Bomb
- SUCCESS：目标进入立即停止模拟
- FAIL：掉出场地或超过 18 秒
- 成功/失败动画
- 程序化音效 / BGM

## 当前技术债

1. Rope 仍是逻辑剪断原型。
2. Gear 仍是简化机械传递。
3. 32 关首轮布局以模板生成，必须经过 Android 真机逐关验证后再冻结。
4. UI 和部分玩法编排仍集中在 `main.gd`。
5. Android 导出仍是 debug APK；正式发布需要签名 AAB。

## 下一轮工作

```text
自动化修复回归 → P3 APK → Android 真机逐关测试
                         ↓
                 记录问题/修复/再 CI
                         ↓
                    冻结官方关卡
                         ↓
                         P4
```
