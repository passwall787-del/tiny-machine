# 当前项目状态 / Handoff

> 后续开发人员开始工作前最应该阅读本文档。

## 当前阶段

**P1：机关系统与终端通关状态（进行中）**

P0 的基础物理核心已经进入 P1。当前重点从“单纯让小球运动”转向“机械机关产生连锁反应”。

## 已实现

### 基础系统

- Godot 4.7.2。
- Android ARM64 导出。
- 小球 RigidBody2D。
- 木板 StaticBody2D。
- 斜坡 StaticBody2D + CollisionPolygon2D。
- 目标 Area2D。
- 游戏区域边界。
- 鼠标拖动与 Android 触摸拖动。
- 开始 / 暂停 / 继续 / 重置。
- 高对比度 UI。
- 关卡选择。

### P1 机关

- Spring：一次性冲量。
- Switch：触发后激活机关。
- Gear：持续旋转 + 一次性切向冲量。
- Rope：可剪断视觉原型。
- Scissors：触发剪绳。
- Balloon：上浮。

### P1 通关规则

目标区域进入后是一次模拟的**终端事件**：

```text
RUNNING
  ↓ ball enters target
SUCCESS
  ↓
freeze dynamic bodies
stop component simulation
clear velocities
lock editing controls
```

不会继续让物理系统在已经通关的状态下运行。

## P1 演示关卡

### Level 01

P0 基础斜坡关卡，作为 P1 回归测试。

### Level 02

P1 机关演示，包含：

```text
小球 → 斜坡 → 开关 → 齿轮/弹簧 → 木板 → 目标
```

并放置绳子、剪刀、气球用于组件测试。

## 最近构建记录

### P1 build 19

- GitHub Actions Run：`33157898382`
- Commit：`cf18a82d0b68095da0b0ab885088a5ff17e70add`
- 状态：**success**
- APK：`TinyMachineP1.apk`
- 架构：Android ARM64
- APK 大小：28,267,151 bytes
- SHA-256：`29f213a71887fc624857048d394585dd7acf0e254ea29fcbef3d98366ba8e942`
- Release：`tiny-machine-p1-19`

> CI 成功只代表项目成功导入并导出 APK；真实 Android 设备上的触摸、物理手感和关卡可解性仍需人工回归。

## 当前技术债

1. `main.gd` 仍承担 UI、关卡、物理编排和组件创建。
2. 组件仍通过 `piece_type` 字符串区分。
3. 关卡仍硬编码。
4. 没有正式 Level 数据格式。
5. 没有独立 PhysicsWorld。
6. Rope 还不是实际物理约束。
7. Gear 是原型级机械传递，不是严格齿轮约束求解。
8. 没有正式保存系统。
9. 没有音频系统。

## P1 剩余工作

1. Magnet / Bomb。
2. 更真实的 Rope + Joint2D。
3. 动态跷跷板 / 铰链。
4. 正式 Level 数据结构。
5. ComponentFactory。
6. 独立 GameState / LevelRuntime。
7. P1 关卡可解性验证矩阵。
8. Android 真机回归并记录结果。

## 暂不开发

在核心物理和关卡可解性稳定前，不优先开发登录、服务器、在线关卡、排行榜、广告和内购。

## 代码入口

- `main.gd`：当前运行时、关卡和机关编排。
- `piece.gd`：组件交互、物理辅助和绘制。
- `main.tscn`：主场景。
- `project.godot`：项目设置。
- `export_presets.cfg`：Android 导出。
- `.github/workflows/android-p0.yml`：当前 P1 Android CI 工作流（文件名保留历史名称）。

## 文档维护规则

影响状态机、组件行为、关卡布局、Android 构建或验收状态的修改，必须同步更新 `docs/GAMEPLAY.md`、`docs/COMPONENTS.md`、具体关卡文档、`docs/BUILD_ANDROID.md`、`docs/TEST_PLAN.md` 或 `CHANGELOG.md` 中对应内容。
