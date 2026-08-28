# 当前项目状态 / Handoff

> 后续开发人员开始工作前最应该阅读本文档。

## 当前阶段

**P1：机关系统与终端通关状态**

P0 的基础物理核心已经进入 P1。当前重点从“单纯让小球运动”转向“机械机关产生连锁反应”。

## 已实现

### 基础系统

- Godot 4.7.2 项目。
- Android ARM64 导出。
- 小球 RigidBody2D。
- 木板 StaticBody2D。
- 斜坡 StaticBody2D + CollisionPolygon2D。
- 目标 Area2D。
- 游戏区域边界。
- 鼠标拖动。
- Android 触摸拖动。
- 开始/暂停/继续。
- 重置。
- 高对比度 UI。
- 关卡选择。

### P1 机关

- Spring 弹簧：一次性冲量。
- Switch 开关：触发后激活机关。
- Gear 齿轮：持续旋转 + 一次性切向冲量。
- Rope 绳子：可剪断视觉原型。
- Scissors 剪刀：触发剪绳。
- Balloon 气球：上浮。

### P1 通关规则

目标区域进入后：

```text
RUNNING
  ↓ ball enters target
SUCCESS
  ↓
freeze all dynamic bodies
stop component simulation
clear velocities
lock editing controls
```

**不会继续让物理系统在已通关状态下运行。**

## P1 演示关卡

### Level 01

保留 P0 基础斜坡关卡，作为回归测试。

### Level 02

P1 机关演示：

```text
小球
 ↓
斜坡
 ↓
开关
 ↓
齿轮 / 弹簧
 ↓
木板
 ↓
目标
```

场景中同时放置绳子、剪刀和气球，方便直接测试组件。

## 当前技术债

1. `main.gd` 仍然承担 UI、关卡、物理编排和组件创建。
2. 组件仍通过 `piece_type` 字符串区分。
3. 关卡仍硬编码。
4. 没有正式 Level 数据格式。
5. 没有独立 PhysicsWorld。
6. Rope 还不是实际物理约束。
7. Gear 目前是原型级旋转传递，不是齿轮约束求解。
8. 没有正式保存系统。
9. 没有音频系统。

## 下一阶段

P1 完成后优先：

1. Magnet / Bomb。
2. 更真实的 Rope + Joint2D。
3. 动态跷跷板/铰链。
4. 正式 Level 数据结构。
5. 组件工厂。
6. 独立 GameState / LevelRuntime。

## 暂不开发

在核心物理和关卡可解性稳定前，不优先开发：

- 登录
- 服务器
- 在线关卡
- 排行榜
- 广告
- 内购

## 代码入口

- `main.gd`：当前运行时、关卡和机关编排。
- `piece.gd`：组件交互、物理辅助和绘制。
- `main.tscn`：主场景。
- `project.godot`：项目设置。
- `export_presets.cfg`：Android 导出。
- `.github/workflows/android-p0.yml`：当前 Android CI 文件，后续应重命名为 P1 workflow。
