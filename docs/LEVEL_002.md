# Level 002 · P1 机关演示

## 状态

**P1 演示 / 集成测试关卡**

## 目标

让小球通过基础斜坡进入目标，并在途中体验 P1 机关的触发关系。

## 预置组件

```text
Slope × 3
Switch × 1
Gear × 1
Spring × 1
Board × 1
Rope × 1
Scissors × 1
Balloon × 1
Ball × 1
Target × 1
```

## 主要链路

```text
Ball
  ↓
Slope 1
  ↓
Slope 2
  ↓
Switch
  ↓
Gear / Spring
  ↓
Board
  ↓
Target
```

## 辅助机关

左下区域提供 Rope + Scissors，用于直接验证剪断状态。

上方提供 Balloon，用于验证独立 RigidBody2D 上浮行为。

## P1 通关语义

一旦 Ball 进入 Target：

```text
RUNNING
  ↓
SUCCESS
  ↓
Freeze + zero velocity + stop components
```

不允许成功后继续模拟。

## 测试项目

- [ ] Switch 可以触发。
- [ ] Gear 激活并旋转。
- [ ] Spring 只触发一次。
- [ ] Rope 初始完整。
- [ ] Scissors 可以剪断 Rope。
- [ ] Balloon 上浮。
- [ ] Ball 能完成目标。
- [ ] 成功后全部停止。
- [ ] Reset 后所有组件恢复。
- [ ] Android 触摸可以移动所有组件。

## 注意

Rope 和 Gear 在 P1 仍属于原型实现：

- Rope 不是完整物理约束。
- Gear 不是严格的齿轮接触求解。

这些属于后续物理深化任务。
