# 组件规范

## 1. 设计目标

每种机关都应该是一个可以独立理解、独立测试、独立重置的组件。

组件必须明确：

- 视觉表现。
- 碰撞体/检测范围。
- 物理类型。
- 输入方式。
- 运行行为。
- 触发条件。
- 重置行为。
- 可用参数。

## 2. 当前组件

| 组件 | P1 状态 | 物理类型 | 主要作用 |
|---|---|---|---|
| Ball / 小球 | 已实现 | RigidBody2D | 基础动态物体、目标对象 |
| Board / 木板 | 已实现 | StaticBody2D | 碰撞面、导向 |
| Slope / 斜坡 | 已实现 | StaticBody2D + CollisionPolygon2D | 改变运动方向/高度 |
| Target / 目标区 | 已实现 | Area2D | 终端通关判定 |
| Spring / 弹簧 | P1 已实现 | StaticBody2D + 距离触发 | 一次性弹射 |
| Rope / 绳子 | P1 原型 | StaticBody2D + 状态 | 连接/可剪断的视觉原型 |
| Scissors / 剪刀 | P1 已实现 | StaticBody2D + 距离检测 | 剪断绳子 |
| Gear / 齿轮 | P1 已实现 | AnimatableBody2D | 旋转与一次性切向冲量 |
| Switch / 开关 | P1 已实现 | StaticBody2D + 距离触发 | 激活机关 |
| Balloon / 气球 | P1 已实现 | RigidBody2D | 上浮 |

## 3. 后续组件优先级

| 优先级 | 组件 | 玩法价值 |
|---:|---|---|
| P1-7 | Magnet 磁铁 | 吸附/排斥 |
| P1-8 | Bomb 炸弹 | 延时/爆炸冲量 |
| P2 | 动态跷跷板 | 铰链/转动 |
| P2 | 活塞 | 方向性往复运动 |
| P2 | Conveyor | 连续输送 |

## 4. 组件生命周期

```text
Create
  ↓
Configure
  ↓
Edit
  ↓
Start Simulation
  ↓
Running
  ↓
Success / Failure / Stop
  ↓
Reset
  ↓
Edit
```

## 5. P1 组件状态

组件状态统一使用以下概念：

```text
active
triggered
cut
simulation_enabled
```

并由 `reset_piece()` 恢复初始状态。

## 6. 物理原则

- 固体组件使用 collision layer 1。
- 仅用于触发/编辑的组件使用独立碰撞层，避免阻挡小球。
- 视觉几何必须与碰撞几何保持一致。
- 一次性冲量只能在触发事件发生时施加，不能每帧重复施加。
- 动态组件优先使用 RigidBody2D；长期固定组件使用 StaticBody2D；需要程序旋转的固定组件使用 AnimatableBody2D。

## 7. P1 具体规则

### Spring

触发半径约 72 px；每次运行只触发一次。冲量方向由组件 rotation 决定。

### Switch

触发半径约 62 px。触发后保持 ON，并激活关卡中的 gear/spring。

### Gear

激活后持续视觉旋转。小球进入约 76 px 范围后产生一次切向冲量。

### Rope

当前版本是“可剪断视觉原型”，不承担真正的约束力。正式物理绳索应使用 Joint2D 系列实现。

### Scissors

进入绳子约 90 px 范围后执行一次 `cut_rope()`。

### Balloon

RigidBody2D，使用负 gravity_scale + 向上恒力模拟上浮。

## 8. 组件测试要求

每个新组件至少需要：

1. 独立放置测试。
2. 独立运行测试。
3. Reset 测试。
4. 边界碰撞测试。
5. Android 触摸测试。
6. 与至少一个其他组件组合测试。
7. 通关终止状态测试。

## 9. 组件工厂规划

P2 前继续允许 `main.gd` 创建组件，但不要新增更多业务逻辑到创建函数。下一次架构重构时抽取：

```text
ComponentFactory.create(component_definition)
```

工厂只负责实例化；具体组件负责自己的行为。

## 10. 视觉规范

组件应保持：

- 轮廓清晰。
- 运行前后状态明显。
- 选中状态高亮。
- 可拖拽区域足够大。
- 手机小屏可识别。
- 功能按钮不能与背景处于相近亮度层级。
