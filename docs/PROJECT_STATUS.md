# 当前项目状态 / Handoff

> 这是后续开发人员开始工作前最应该阅读的文档。

## 当前阶段

**P0：物理核心验证**

项目已经可以构建 Android ARM64 测试 APK。当前最重要的工作不是服务器，而是把核心物理和手机交互验证稳定。

## 当前已实现

- Godot 项目基础结构。
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
- 目标进入判定。
- 基础 UI。
- GitHub Actions 自动 APK 构建。

## 最近修复

### 第一关不可解

原因：斜坡的视觉几何、碰撞几何和旋转方向没有经过完整的运行时验证。

处理：重新设计第一关的三段斜坡路线，增加底部和左右边界，并明确要求每次新增倾斜组件都进行可解性验证。

### 按钮不可见

原因：按钮与深色背景明度接近。

处理：主操作使用蓝色强调色，普通按钮使用独立深色面板和边框，文字使用高对比度颜色。

## 当前技术债

1. `main.gd` 职责过多。
2. 组件通过字符串 `piece_type` 区分。
3. 关卡硬编码。
4. UI 动态创建。
5. 没有正式 Level 数据格式。
6. 没有独立的 PhysicsWorld。
7. 没有正式保存系统。
8. 没有音频系统。

这些不是 P0 bug，而是计划中的架构演进。

## 下一步建议

### 第一优先级

让用户在 Android 真机上完整测试 P0。

重点反馈：

- 触摸拖动手感。
- 斜坡是否自然。
- 小球速度是否合适。
- 按钮是否足够明显。
- 第一关是否一眼能理解。
- Reset 是否可靠。

### 第二优先级

如果 P0 手感确认：

1. 抽取 `MachineComponent` 基类。
2. 抽取 `GameState`。
3. 抽取 `LevelRuntime`。
4. 抽取 `GoalSystem`。
5. 再开始 P1 机关。

## 不要做的事情

在 P0 手感确认前，不要优先开发：

- 登录
- 服务器
- 在线关卡
- 排行榜
- 广告
- 内购

## 代码入口

- `main.gd`：当前游戏主逻辑。
- `piece.gd`：当前组件逻辑。
- `main.tscn`：主场景。
- `project.godot`：项目设置。
- `export_presets.cfg`：Android 导出。
- `.github/workflows/android-p0.yml`：Android CI。
