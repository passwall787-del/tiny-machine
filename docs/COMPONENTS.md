# 组件说明

| 组件 | 物理类型 | P3 行为 |
|---|---|---|
| Ball | RigidBody2D | 目标对象，受重力影响 |
| Board | StaticBody2D | 固定平台 |
| Slope | StaticBody2D | 倾斜导轨 |
| Spring | Area2D | 触发后给小球一次冲量 |
| Switch | Area2D | 触发后激活弹簧/齿轮 |
| Gear | AnimatableBody2D | 激活后旋转并给切向冲量 |
| Rope | Area2D | 可被剪刀剪断的逻辑组件 |
| Scissors | Area2D | 近距离剪断绳子 |
| Balloon | RigidBody2D | 向上产生浮力 |
| Magnet | Area2D | 近距离持续吸引小球 |
| Bomb | Area2D | 接近后一次性爆炸冲量 |

## 编辑规则
所有组件都通过 `ComponentFactory` 创建，位置/旋转统一由 `LevelData` 描述。编辑状态支持拖动、旋转、多选、删除、撤销、重做和网格吸附。

## 物理层
Solid：Ball / Board / Slope / Gear / Balloon 使用 layer 1。
Sensor：Spring / Switch / Rope / Scissors / Magnet / Bomb 使用 layer 2，不阻挡小球。

## P1→P3 的保留项
Rope 和 Gear 仍属于原型级实现：后续可替换成 Joint2D/轮轴约束，而不需要修改 LevelData 接口。
