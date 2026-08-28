# 架构设计

## 1. 当前 P0 架构

当前原型采用极简结构：

```text
Main Node2D
├── main.gd
│   ├── UI 构建
│   ├── Level 1 构建
│   ├── Physics World 边界
│   ├── Run/Pause/Reset
│   └── Goal 判定
│
└── MachinePiece
    └── piece.gd
        ├── 拖动
        ├── 初始状态
        ├── 重置
        └── 绘制
```

`main.gd` 目前故意承担较多职责，以便快速验证 P0。

## 2. 当前核心对象

### Main

职责：

- 创建 UI
- 创建关卡
- 保存 `pieces`
- 管理运行状态
- 管理目标
- 管理选中组件
- 创建边界

不应在长期版本继续承担所有职责。

### MachinePiece

当前是所有组件的基础类型，通过 `piece_type` 字符串区分 `ball`、`board`、`slope`。

长期目标：改成组件类型/场景注册机制，避免大量 `if kind == ...`。

## 3. 推荐 P1 架构

```text
GameRoot
├── GameState
├── LevelRuntime
│   ├── LevelDefinition
│   ├── ComponentFactory
│   └── GoalSystem
│
├── PhysicsWorld
│   ├── Boundaries
│   └── MachineComponents
│
├── InputController
├── UI
│   ├── TopBar
│   ├── Palette
│   └── StatusPanel
│
└── Audio
```

## 4. 数据层

P1 开始应该把“关卡定义”和“运行实例”分开：

```text
LevelDefinition
  ├── id
  ├── title
  ├── world_size
  ├── available_components
  ├── initial_components
  └── goals

LevelRuntime
  ├── instantiated components
  ├── current state
  ├── elapsed time
  └── result
```

## 5. 组件接口

建议统一接口：

```gdscript
class_name MachineComponent

func configure(data: Dictionary) -> void:
    pass

func capture_initial_state() -> void:
    pass

func reset_state() -> void:
    pass

func on_simulation_start() -> void:
    pass

func on_simulation_stop() -> void:
    pass
```

具体组件只实现自己的特殊行为。

## 6. 目标系统

目标不要写死为“小球进入圆圈”。应抽象为：

```text
Goal
├── BallEnterAreaGoal
├── ObjectReachPositionGoal
├── SwitchActivatedGoal
├── MultiConditionGoal
└── TimedGoal
```

未来可使用组合条件：

```text
AND
├── BallEnterArea
└── SwitchActivated
```

## 7. 输入系统

输入层应把鼠标和触摸统一成逻辑事件：

```text
Mouse / Touch
      ↓
PointerEvent
      ↓
Selection
      ↓
DragController
      ↓
Component
```

不要让组件业务逻辑依赖 Android 具体输入 API。

## 8. UI 系统

P0 当前用 GDScript 动态创建 UI。P1 建议拆成 `.tscn`：

```text
ui/
├── hud.tscn
├── palette.tscn
├── pause_menu.tscn
└── level_result.tscn
```

## 9. 数据流

```text
Level JSON
   ↓
LevelLoader
   ↓
ComponentFactory
   ↓
PhysicsWorld
   ↓
Simulation
   ↓
GoalSystem
   ↓
GameState
   ↓
UI
```

## 10. 重构时机

不要为了“架构漂亮”提前重写 P0。满足以下任一条件再重构：

- 组件数量 > 8
- 关卡数量 > 5
- `main.gd` > 500 行
- 新增组件需要修改多个无关模块
- 无法独立测试组件

## 11. 性能原则

目标设备：普通 Android 手机。

优先保证：

- 物理步进稳定
- UI 不频繁创建/销毁
- 不在 `_process` 中做昂贵遍历
- 组件数量增加后使用对象生命周期管理
- 粒子和特效必须有限制

正式版本目标：简单关卡 60 FPS；复杂关卡至少保持可玩帧率。
