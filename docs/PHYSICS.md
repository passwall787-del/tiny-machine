# 物理系统

## 1. 引擎

- Godot 4.7.2
- 2D physics
- Ball / Balloon 使用 RigidBody2D
- 固定碰撞面使用 StaticBody2D
- Gear 使用 AnimatableBody2D 原型

Godot 的 RigidBody2D 应通过力/冲量驱动，而不是在运行中直接持续修改位置。P1 的弹簧和齿轮使用一次性 `apply_central_impulse()` 触发。citeturn5search2turn2search6

## 2. 碰撞层

### Layer 1

真实物理实体：

- Ball
- Board
- Slope
- Gear
- Balloon

### Layer 2

编辑/触发组件：

- Spring
- Rope
- Scissors
- Switch

它们不应该阻挡 Ball。

### Target

Target 是 Area2D，使用 mask 检测 Ball。Area2D 的 `body_entered` 用于接收 PhysicsBody2D 进入事件。citeturn0search2

## 3. P1 触发模型

```text
Ball position
     ↓
component trigger radius
     ↓
component.triggered
     ↓
one-shot impulse / state change
```

一次性冲量不能放在每帧循环中，否则会产生帧率相关行为；Godot 文档明确将 central impulse 定义为一次性冲击用途。citeturn5search2

## 4. Spring

- Trigger radius：约 72 px。
- 每次运行最多触发一次。
- 方向：`Vector2.RIGHT.rotated(rotation)`。
- 默认冲量：约 620。

## 5. Gear

- 激活后持续旋转。
- 小球进入约 76 px 后产生一次切向冲量。
- 当前只是 P1 原型，不是严格齿轮约束求解。

## 6. Balloon

- RigidBody2D。
- 初始 gravity_scale 为负值。
- 运行期间额外施加向上力。
- Reset 时恢复 freeze、速度和位置。

## 7. Rope

当前 P1 只实现：

- 完整状态。
- 剪断状态。
- 视觉断裂。

尚未实现真实约束。

后续正式绳索应考虑 Joint2D。Godot 的 Joint2D 用于绑定两个 PhysicsBody2D 并施加约束。citeturn3search1

## 8. Pause

Pause：

- freeze RigidBody2D。
- 禁止组件逻辑继续运行。
- 不清零当前速度。

Resume：

- 解除 freeze。
- 恢复组件 simulation_enabled。

## 9. Success / 终止

目标进入事件是硬终止：

```text
Area2D.body_entered
        ↓
GameState.SUCCESS
        ↓
freeze all RigidBody2D
        ↓
zero velocity
        ↓
disable component simulation
```

这样通关截图/状态不会因为后续物理运动而改变。

## 10. 可解性要求

每个关卡必须：

- 有稳定解。
- 不依赖极端碰撞角度。
- 不依赖随机初始速度。
- Android 上重复运行结果基本一致。
