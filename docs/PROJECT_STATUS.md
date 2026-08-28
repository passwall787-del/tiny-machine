# 项目当前状态 / Handoff

## 当前阶段

**P3 首轮交付，进入真机体验与内容调优循环。**

P2 已完成首版关卡编辑器与数据管线；P3 已加入 32 个官方关卡、教程、难度曲线、成功/失败反馈、程序化音效和轻量 BGM。

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

## P2 功能

- 拖动
- 旋转 15°
- 多选移动
- 删除
- 撤销 / 重做（最多 50 步）
- 20px 网格吸附
- 保存 `user://tiny_machine_custom_level.json`
- 加载本机自制关卡
- 关卡验证

## P3 功能

- 官方关卡：32
- 教程：1~5 关
- 难度：1~8 星
- Magnet / Bomb 已进入组件工厂和运行时
- 成功状态：目标进入后立即停止模拟
- 失败状态：掉出场地或超过 18 秒
- 成功/失败动画
- 程序化音效 / BGM，可关闭

## 官方关卡策略

`levels.json` 保存关卡元数据；`LevelData.generate_pattern()` 根据 pattern 和 slope_count 生成首轮官方布局。这样后续可以逐步把经过验证的关卡冻结为显式 JSON，而不需要改运行时架构。

## 自动化测试

CI 在导出 APK 前执行：
- JSON 解析
- 32 关数量检查
- ID 唯一性
- 组件类型合法性
- 目标边界
- 每关恰好一个小球
- LevelData 序列化往返
- Validator 负例

## 已知技术债 / 下一轮

1. Rope 当前仍是逻辑剪断原型，不是 Joint2D 绳索求解。
2. Gear 当前是原型级机械传递，后续可改为真正的轮轴/齿轮约束。
3. 官方关卡首轮以可运行路径为主，必须通过 Android 真机反馈继续调成真正的谜题，而不是只依赖固定模板。
4. 当前主场景仍集中了一部分 UI 与编排逻辑；后续可以进一步拆分编辑器 UI 与游戏运行时。

## 验收规则

每次修改物理、组件、目标或关卡数据后，都必须先通过 headless 自动测试，再导出 Android APK。真实触摸手感、性能、音频和关卡可解性仍需要真机回归。
