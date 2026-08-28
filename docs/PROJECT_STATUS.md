# 项目当前状态 / Handoff

## 当前阶段

**P3 首轮交付：代码级自动化回归通过，APK 已生成；下一步进入 Android 真机逐关体验回归。**

P2 已完成首版关卡编辑器与数据管线；P3 已加入 32 个官方关卡、教程、难度曲线、成功/失败反馈、程序化音效和轻量 BGM。

## 最近自动化回归循环

- Run 23：发现主脚本静态类型转换问题 → 修复。
- Run 24：发现 typed `Array[Dictionary]` 赋值问题 → 修复。
- Run 26：发现基础坡道数量不足导致默认关卡不可解 → 修复。
- Run 29~33：发现坡面摩擦、目标命中、机关默认位置等问题 → 修复。
- Run 34：发现高速测试的 timeout 与 `Engine.time_scale` 叠加导致误报失败 → 修复测试参数。
- Run 35：目标位置调整后构建通过，但 playability runner 暴露了初始化时机问题。
- Run 36：修正 runner 初始化与 32 关硬门禁；32 个官方默认布局实际逐关运行并通过。
- Run 37：补齐项目图标与 P3 首轮内容收尾；脚本、数据、runtime smoke、32 关可玩性和 APK 导出全部通过。
- Run 38：再次验证当前代码，32 关可玩性、脚本/数据、runtime smoke、Android ARM64 导出和签名全部通过；临时 Litterbox 上传返回 500，但 GitHub Release 正常发布。
- Run 39：发现 playability runner 日志修复引入 GDScript 参数/类型解析错误 → 修复。
- Run 40：修复后的 runner 通过；明确日志输出 `PASS (32 levels)`，并再次完成全部自动化门禁、APK 导出和签名验证。
- Run 41：移除不稳定的临时 Litterbox 分发步骤；32 关可玩性、脚本/数据、runtime smoke、Android ARM64 导出和签名再次全部通过，GitHub Release 成为唯一正式公共 APK 来源。

## 当前自动化门禁

- 核心 `.gd` 可加载且可实例化。
- 32 个官方关卡结构验证。
- 主场景 runtime smoke。
- 32 个官方默认布局实际运行到 SUCCESS。
- Android ARM64 APK 导出并完成 APK 签名校验。
- Release 只有在构建步骤成功后才创建。

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
- Android ARM64 debug APK
- headless 自动化数据、runtime smoke、默认布局可玩性测试

## 当前技术债

1. Rope 仍是逻辑剪断原型。
2. Gear 仍是简化机械传递。
3. 32 关已通过默认布局自动回归，但仍需要 Android 真机逐关体验测试和难度调整。
4. UI 和部分玩法编排仍集中在 `main.gd`。
5. Android 当前为 debug APK；正式发布需要签名 AAB。

## 当前构建

- Release：`tiny-machine-p3-41`
- APK：`TinyMachineP3.apk`
- SHA-256：`14604768874c1bd87ea87db8784b64024bbd7a48394fbb351eada1963e0f38ef`
- 公共下载：GitHub Release `tiny-machine-p3-41`

## 下一步

```text
P3 APK → Android 真机逐关测试 → 记录问题 → 修复 → CI → 再真机
                                      ↓
                              冻结官方关卡
                                      ↓
                                      P4
```
