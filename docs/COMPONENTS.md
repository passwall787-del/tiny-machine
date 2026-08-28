# 组件规范

## 1. 设计目标

每种机关都应该是一个可以独立理解、独立测试、独立重置的组件。

组件必须明确：

- 视觉表现
- 碰撞体
- 物理类型
- 输入方式
- 运行行为
- 触发条件
- 重置行为
- 可用参数

## 2. 当前组件

### Ball / 小球

类型：RigidBody2D

用途：基础动态物体，也是 P0 的目标对象。

关键参数：

- radius
- mass
- gravity_scale
- damping

### Board / 木板

类型：StaticBody2D（P0）

用途：提供碰撞面和方向改变。

未来可支持：

- 动态跷跷板
- 旋转
- 铰链

### Slope / 斜坡

类型：StaticBody2D

用途：改变小球运动方向和高度。

关键要求：视觉斜边和碰撞斜边一致。

### Target / 目标区

类型：Area2D

用途：判断任务完成。

P0：只检测小球进入区域。

## 3. P1 组件优先级

| 优先级 | 组件 | 玩法价值 |
|---:|---|---|
| P1-1 | Spring 弹簧 | 弹射、储能 |
| P1-2 | Rope 绳子 | 连接、约束 |
| P1-3 | Scissors 剪刀 | 破坏连接 |
| P1-4 | Gear 齿轮 | 旋转传递 |
| P1-5 | Switch 开关 | 条件触发 |
| P1-6 | Balloon 气球 | 浮力 |
| P1-7 | Magnet 磁铁 | 吸附 |
| P1-8 | Bomb 炸弹 | 延时/冲量 |

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

## 5. 组件数据

未来组件定义建议采用：

```json
{
  "type": "spring",
  "position": [500, 300],
  "rotation": 0.0,
  "properties": {
    "strength": 800,
    "cooldown": 0.2
  }
}
```

不要把关卡参数直接写进组件脚本。

## 6. 组件工厂

P1 建议使用：

```text
ComponentFactory.create(component_definition)
```

工厂只负责实例化；具体组件负责自己的行为。

## 7. 组件测试要求

每个新组件至少需要：

1. 独立放置测试。
2. 独立运行测试。
3. 重置测试。
4. 边界碰撞测试。
5. Android 触摸测试。
6. 与至少一个其他组件组合测试。

## 8. 视觉规范

组件应保持统一：

- 轮廓清晰
- 运行前后状态明显
- 选中状态有高亮
- 可拖拽区域足够大
- 手机小屏上仍能识别

不要让功能按钮、组件和背景使用相同亮度层级。
