# 架构说明

## 1. 当前运行时

当前 P1 仍采用轻量原型架构：

```text
main.tscn
   │
   └── main.gd
        ├── UI
        ├── Level Runtime
        ├── GameState
        ├── Target / Goal
        ├── Physics orchestration
        └── MachinePiece[]
              └── piece.gd
```

## 2. GameState

正式状态：

```text
EDITING
RUNNING
PAUSED
SUCCESS
```

目标进入是终端事件：

```text
Target.body_entered
      ↓
SUCCESS
      ↓
freeze bodies + stop components + lock UI
```

## 3. MachinePiece 包装模型

P1 中 `MachinePiece` 是一个 `Node2D` 脚本类型，实际承载它的节点仍然是：

- RigidBody2D
- StaticBody2D
- AnimatableBody2D

这样同一个组件行为脚本可以同时服务动态和静态物理节点。

需要物理属性时通过 `CollisionObject2D` / `RigidBody2D` 进行运行时类型检查。

## 4. 组件

P1 组件使用 `MachinePiece` 统一脚本，通过 `piece_type` 分发行为。

当前类型：

```text
ball
board
slope
spring
rope
scissors
gear
switch
balloon
```

## 5. 物理层

### Solid layer

- Ball
- Board
- Slope
- Gear
- Balloon

使用 layer 1 / mask 1。

### Sensor/edit layer

- Spring
- Rope
- Scissors
- Switch

使用独立碰撞层，避免无意阻挡小球。

## 6. 运行时职责

`main.gd`：

- 创建关卡。
- 管理 GameState。
- 管理目标判定。
- 管理暂停/恢复/重置。
- 编排 P1 机关之间的触发关系。

`piece.gd`：

- 拖动。
- 组件状态。
- 组件绘制。
- Balloon 上浮。
- Gear 旋转。
- Rope cut。
- RigidBody2D 冲量辅助。

## 7. P1 的临时取舍

当前没有立即拆成大量脚本，因为需要先验证物理手感和机关规则。

但是新增 P1 组件不能继续把大量独立业务塞进 `main.gd`。进入 P2 前应拆分为：

```text
GameState
LevelRuntime
GoalSystem
ComponentFactory
MachineComponent
SpringComponent
RopeComponent
ScissorsComponent
GearComponent
SwitchComponent
BalloonComponent
```

## 8. 后续数据驱动架构

目标：

```text
Level Resource / JSON
        ↓
ComponentFactory
        ↓
MachineComponent instances
        ↓
LevelRuntime
        ↓
PhysicsWorld
        ↓
GoalSystem
```

关卡数据不得长期硬编码在 `main.gd`。
