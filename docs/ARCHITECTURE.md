# 架构说明

## P2/P3 运行时

```text
main.tscn
  │
  └── main.gd
       ├── LevelRuntime
       │    ├── ComponentFactory
       │    │     └── MachineComponent
       │    └── Goal Area2D
       ├── LevelData
       │    └── levels.json
       ├── LevelValidator
       └── AudioManager
```

## 职责

### main.gd
- UI 与输入编排
- GameState
- 编辑器操作
- 运行时机关链
- 成功/失败流程

### LevelData
负责关卡元数据、组件布局、JSON 序列化和模板生成。

### LevelValidator
在运行和保存前检查组件类型、坐标、目标和小球数量。

### ComponentFactory
把 `type + transform` 数据转换成 Godot 物理节点并安装统一组件脚本。

### MachineComponent
负责拖动输入、运行时状态和组件绘制。当前组件类型：
`ball / board / slope / spring / rope / scissors / gear / switch / balloon / magnet / bomb`

### LevelRuntime
负责创建/清理目标、实例化组件、重置模拟和导出当前布局。

### AudioManager
使用 `AudioStreamGenerator` 产生轻量程序化 BGM、点击、成功和失败提示，不依赖外部音频资源。

## 状态机

```text
EDITING → RUNNING → SUCCESS
    │         │
    │         └────→ FAIL
    │
    └──────────────→ EDITING (重置)
```

目标区进入是终端事件：

```text
ball enters goal
      ↓
SUCCESS
      ↓
stop simulation + zero velocities + lock editor + success animation
```

## 数据流

```text
levels.json
   ↓
LevelData
   ↓
LevelValidator
   ↓
LevelRuntime
   ↓
ComponentFactory
   ↓
MachineComponent / Godot physics
```

编辑器修改后反向生成 `LevelData`；保存时写入 `user://`。

## P2 后续演进

正式版本可进一步把 `main.gd` 拆为 `EditorController`、`GameStateController`、`MechanicsSystem` 和 `GoalSystem`。当前结构已经先把数据、组件工厂、运行时和验证器分开，避免继续把关卡硬编码在单文件中。
