# 物理系统

## 引擎
- Godot 4.7.2
- 2D Physics
- Ball / Balloon：RigidBody2D
- Board / Slope：StaticBody2D
- Gear：AnimatableBody2D 原型
- 触发机关：Area2D

## 碰撞层
Layer 1：Ball / Board / Slope / Gear / Balloon。
Layer 2：Spring / Switch / Rope / Scissors / Magnet / Bomb，不阻挡 Ball。
Target：Area2D，mask 检测 Layer 1。

## 机关
Spring：一次性 impulse 620。
Switch：触发后激活 Spring/Gear。
Gear：激活后旋转，并在接近时给一次切向 impulse。
Rope：当前是可剪断逻辑原型。
Scissors：近距离剪断 Rope。
Balloon：额外向上力。
Magnet：180px 范围内吸引 Ball，吸力随距离增加而增强。
Bomb：58px 内触发一次爆炸 impulse；它本身不阻挡 Ball。

## 状态
暂停/成功/失败时停止组件模拟；成功后额外清零动态物体速度。

## 终端通关
`Target.body_entered → SUCCESS → stop simulation → zero velocity → lock editor → animation`。

## 失败
Ball 掉出场地或单次模拟超过 18 秒进入 FAIL。

## 可解性
首轮官方关卡使用默认可运行的斜坡路径；机关摆放在主路径外，避免“展示机关”本身破坏默认解。后续逐关真机验证后再冻结复杂解。

## 后续物理升级
Rope 可升级为 Joint2D/PinJoint2D；Gear 可升级为轮轴/齿轮约束。升级不应改变 LevelData 数据接口。
