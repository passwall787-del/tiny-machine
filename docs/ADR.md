# Architecture Decision Records

## ADR-001：使用 Godot
状态：Accepted

Tiny Machine 是 2D 物理驱动游戏，Godot 提供节点、物理、输入和 Android 导出能力，适合快速迭代。

## ADR-002：使用 Godot 内置 2D Physics
状态：Accepted

先围绕 Godot Physics 验证玩法；只有确定性或约束精度成为瓶颈时才评估替换求解器。

## ADR-003：目标进入是终端事件
状态：Accepted

Ball 进入 Target 后立即进入 `SUCCESS`，冻结动态物体、停止机关逻辑、锁定编辑并展示成功反馈。

## ADR-004：P2 起关卡数据化
状态：Accepted

P0/P1 的硬编码布局只用于早期验证。P2 起统一使用 `LevelData + levels.json + ComponentFactory + LevelRuntime`，编辑器通过同一数据模型保存布局。

## ADR-005：Android 首先支持 ARM64
状态：Accepted

早期减少构建矩阵；正式发布再增加签名 AAB 和渠道配置。

## ADR-006：机关先使用可验证简化模型
状态：Accepted / Temporary

Spring、Switch、Gear、Rope、Scissors、Balloon、Magnet、Bomb 先用可测试的简化规则。Rope/ Gear 后续可升级为 Joint2D/轮轴约束而不改变 LevelData 接口。

## ADR-007：核心玩法离线
状态：Accepted

账号、在线关卡、分享、排行榜进入 P4，不阻塞核心游戏开发。

## ADR-008：参考玩法思想，代码和素材原创
状态：Accepted

只实现同类机械连锁解谜体验，不复制旧游戏代码、素材或受版权保护的关卡数据。

## ADR-009：P3 首轮内容采用模板 + 真机冻结
状态：Accepted

先用数据模板快速形成 32 个官方关卡，自动测试保证结构正确；再通过 Android 真机逐关测试，问题只回写到布局/参数，验证通过后逐步冻结为显式关卡数据。
