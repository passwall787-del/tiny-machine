# 项目当前状态 / Handoff

## 当前阶段

**P3 首轮交付：代码级自动化回归通过，APK 已生成；下一步进入 Android 真机逐关体验回归。**

P2 已完成首版关卡编辑器与数据管线；P3 已加入 32 个官方关卡、教程、难度曲线、成功/失败反馈、程序化音效和轻量 BGM。

## 最近自动化回归循环

- Run 23：发现主脚本静态类型转换问题 → 修复。
- Run 24：发现 typed `Array[Dictionary]` 赋值问题 → 修复。
- Run 26：发现基础坡道数量不足导致默认关卡不可解 → 修复。
- Run 29~33：发现坡面摩擦、目标命中、机关默认位置等问题 → 修复。
- Run 35：基础自动化与 APK 导出通过。
- Run 37：最终代码级门禁通过：脚本检查、32 关数据、runtime smoke、32 关默认布局实际运行到 SUCCESS、Android ARM64 APK 导出全部成功。

## 当前自动化门禁

- 核心 `.gd` 可加载且可实例化。
- 32 个官方关卡结构验证。
- 主场景 runtime smoke。
- 32 个官方默认布局实际运行到 SUCCESS。
- Android ARM64 APK 导出并完成 APK 签名校验。
- Release 只有在上述步骤全部成功后才创建。

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
3. 32 关已通过默认布局自动回归，但仍需要 Android 真机逐关体验测试和难度调整。
4. UI 和部分玩法编排仍集中在 `main.gd`。
5. Android 当前为 debug APK；正式发布需要签名 AAB。

## 当前构建

- Release：`tiny-machine-p3-37`
- APK：`TinyMachineP3.apk`
- SHA-256：`9bbb8931ab7d6ac2b8fa275ba6331fe8621ea9e40dfae6545c402a2aef529334`
- 临时下载：`https://litter.catbox.moe/ojb0tj.apk`（一次性短期链接）

## 下一步

```text
P3 APK → Android 真机逐关测试 → 记录问题 → 修复 → CI → 再真机
                                      ↓
                              冻结官方关卡
                                      ↓
                                      P4
```
