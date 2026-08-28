# 组件说明

| 组件 | 物理类型 | P3 行为 | 玩家获取方式 |
|---|---|---|---|
| Ball | RigidBody2D | 目标对象，受重力影响 | 固定 START 发射源，不占库存 |
| Board | StaticBody2D | 固定平台 | 零件仓库，数量有限 |
| Slope | StaticBody2D | 倾斜导轨 | 零件仓库，数量有限 |
| Spring | Area2D | 触发后给小球一次冲量 | 零件仓库，数量有限 |
| Switch | Area2D | 触发后激活弹簧/齿轮 | 零件仓库，数量有限 |
| Gear | AnimatableBody2D | 激活后旋转并给切向冲量 | 零件仓库，数量有限 |
| Rope | Area2D | 可被剪刀剪断的逻辑组件 | 零件仓库，数量有限 |
| Scissors | Area2D | 近距离剪断绳子 | 零件仓库，数量有限 |
| Balloon | RigidBody2D | 向上产生浮力 | 零件仓库，数量有限 |
| Magnet | Area2D | 近距离持续吸引小球 | 零件仓库，数量有限 |
| Bomb | Area2D | 接近后一次性爆炸冲量 | 零件仓库，数量有限 |

## 编辑规则

所有玩家零件都通过 `ComponentFactory` 创建，位置/旋转统一由 `LevelData` 描述。

玩家流程：

1. 点击零件仓库。
2. 工程件出现在施工区并自动选中。
3. 拖动调整位置。
4. 旋转 15° 或使用网格吸附。
5. 可以多选、删除、撤销、重做。
6. 发射小球后进入物理模拟，零件锁定。

小球由 `LevelRuntime` 单独创建，不加入 `runtime.components`，因此不会被玩家删除、移动，也不会占用零件库存。

## 物理层
Solid：Ball / Board / Slope / Gear / Balloon 使用 layer 1。
Sensor：Spring / Switch / Rope / Scissors / Magnet / Bomb 使用 layer 2，不阻挡小球。

## 视觉要求
组件不能再使用简单几何占位作为最终 P3 UI：

- 有材质主色。
- 有阴影。
- 有轮廓。
- 有状态变化。
- 选中时显示明确的蓝色施工高亮。

当前使用 `MachineComponent._draw()` 做轻量矢量绘制，后续可以无缝替换为正式 Sprite / SVG / 2D 资源。

## P1→P3 的保留项
Rope 和 Gear 仍属于原型级物理实现；后续可替换成 Joint2D / 轮轴约束，而不需要修改 `LevelData` 接口。
