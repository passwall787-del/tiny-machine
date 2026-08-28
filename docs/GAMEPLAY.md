# 游戏规则

## 1. 基本规则

每个关卡提供：

- 初始场景。
- 玩家可使用的组件集合。
- 一个或多个目标条件。
- 可选的操作限制。

玩家在编辑状态摆放组件。点击开始后进入物理模拟；运行期间不能移动普通组件。

## 2. P1 目标终止规则

**目标区域是一次模拟的终端事件。**

当当前关卡的目标对象进入目标区域，并且游戏状态为 `RUNNING` 时：

1. 立即进入 `SUCCESS`。
2. 立即冻结所有 RigidBody2D。
3. 停止所有机关的运行逻辑。
4. 清零动态物体的线速度和角速度。
5. 禁止继续添加/移动组件。
6. 开始按钮变为“✓ 完成”。
7. 显示通关信息。

不能继续让物理系统在“已经通关”的状态下向前跑。

P1 当前成功条件：

```text
ball == level_goal_object
AND
ball enters Target Area
AND
GameState == RUNNING
→ GameState.SUCCESS
→ stop simulation
```

## 3. 游戏状态机

```text
EDITING
   │
   ├── Start ──→ RUNNING
   │               │
   │               ├── Pause ──→ PAUSED
   │               │                │
   │               │                └── Resume ──→ RUNNING
   │               │
   │               └── Goal entered ──→ SUCCESS
   │
   └── Reset ──→ EDITING

RUNNING / PAUSED / SUCCESS
   └── Reset ──→ EDITING
```

P1 暂不引入自动 `FAILED`；失败仍由关卡定义，避免把“暂时没有成功”误判为失败。

## 4. 编辑模式

允许：

- 选择组件。
- 拖动组件。
- 添加组件。
- 选择关卡。

P1 暂不正式支持旋转、删除、撤销/重做；这些进入后续编辑器阶段。

## 5. 运行模式

运行时：

- 物理系统拥有动态物体位置。
- 玩家不能移动组件。
- `PAUSED` 冻结物理，但保留当前状态。
- `SUCCESS` 是终态，直到 Reset。

## 6. 重置规则

Reset 必须恢复：

- position
- rotation
- linear velocity
- angular velocity
- freeze/sleeping
- spring triggered 状态
- switch active 状态
- gear active/rotation 状态
- rope cut 状态
- scissors triggered 状态
- balloon 状态
- target / run state

## 7. P1 机关交互

### Spring

小球进入触发范围后，沿弹簧朝向施加一次性冲量。

### Switch

小球进入触发范围后开关变为 ON，并激活当前关卡中的齿轮/弹簧机关。

### Gear

激活后旋转；小球进入齿轮作用范围时获得一次切向冲量。

### Rope / Scissors

绳子有完整/剪断两种状态。剪刀靠近绳子时将绳子标记为 `cut`，当前 P1 使用可视化断绳模型；正式物理约束将在后续版本改用 Joint2D。

### Balloon

气球是 RigidBody2D，使用负重力倍率并叠加向上力模拟上浮。

## 8. 解题原则

一个关卡必须至少存在一个稳定解：

- 不要求像素级操作。
- 不依赖极端浮点误差。
- 不依赖随机初始速度。
- 在目标 Android 帧率范围内可以重复成功。

## 9. 暂停与调试

暂停必须保留：

- 当前物理位置。
- 当前速度。
- 当前机关状态。
- 当前模拟状态。

未来可加入单帧前进、时间轴和回放。
