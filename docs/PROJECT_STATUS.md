# 项目当前状态 / Handoff

## 当前阶段

**P3 首轮交付，已通过代码级 CI，等待/进行 Android 真机体验回归。**

P2 已完成首版关卡编辑器与数据管线；P3 已加入 32 个官方关卡、教程、难度曲线、成功/失败反馈、程序化音效和轻量 BGM。

## 最近自动化回归

- Run 23：先发现 `MachineComponent` 类型推断导致主脚本解析失败；已修复。
- Run 24：新增 `can_instantiate()` 脚本检查和 runtime smoke test。
- 当前构建流程要求：脚本可实例化 + 32 关数据测试 + 主场景 smoke + Android 导出。

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

优先级不是继续堆功能，而是：

```text
P3 APK → 真机逐关测试 → 记录问题 → 修复 → CI → 再真机
                    ↓
             物理/操作稳定
                    ↓
             冻结官方关卡
                    ↓
                  P4
```
