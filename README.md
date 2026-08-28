# Tiny Machine

Tiny Machine 是一个面向 Android 的 2D 物理机关解谜游戏原型：玩家摆放有限的机械组件，启动模拟，让物理系统自行运行，通过一系列连锁反应完成目标。

> 当前阶段：**P1：机关系统与终端通关状态**。

## 当前状态

- Engine: Godot 4.7.2
- Language: GDScript
- Renderer: GL Compatibility
- Target: Android ARM64（arm64-v8a）
- Package: `com.passwall.tinymachine`
- Build type: Debug/test build
- Levels: 2 个测试关卡
- Components: 小球、木板、斜坡、弹簧、绳子、剪刀、齿轮、开关、气球、目标区
- Input: 鼠标 + Android 触摸
- Backend: 无，当前完全离线

**接手项目先读：[当前项目状态](docs/PROJECT_STATUS.md)。**

## 核心循环

```text
选择/拖动组件
      ↓
调整位置
      ↓
点击「开始」
      ↓
物理模拟运行
      ↓
机关产生连锁反应
      ↓
目标对象进入 Target？
      │
      是
      ↓
立即 SUCCESS
      ↓
冻结物理 + 停止机关 + 锁定编辑
```

## P1 当前功能

- 小球、木板、斜坡基础物理。
- Spring 一次性弹射。
- Switch 触发机关。
- Gear 旋转和一次性切向冲量。
- Rope 剪断视觉原型。
- Scissors 剪绳。
- Balloon 上浮。
- Level 01 基础物理回归。
- Level 02 P1 机关演示。
- 关卡选择。
- Android 触摸编辑。
- 高对比度 UI。
- 目标进入后立即终止本次模拟并判定通关。

## 项目结构

```text
.
├── project.godot
├── export_presets.cfg
├── main.tscn
├── main.gd
├── piece.gd
├── docs/
├── CHANGELOG.md
├── CONTRIBUTING.md
└── .github/workflows/
```

## 文档入口

完整文档索引：[docs/INDEX.md](docs/INDEX.md)

| 文档 | 内容 |
|---|---|
| [当前项目状态](docs/PROJECT_STATUS.md) | 实现、技术债、下一步和交接 |
| [产品与范围](docs/PRODUCT.md) | 产品定位和阶段边界 |
| [游戏规则](docs/GAMEPLAY.md) | 状态机、目标终止、机关规则 |
| [架构](docs/ARCHITECTURE.md) | 当前架构和后续拆分 |
| [物理系统](docs/PHYSICS.md) | 物理、碰撞、触发和终止 |
| [组件规范](docs/COMPONENTS.md) | P1 组件和生命周期 |
| [关卡设计](docs/LEVEL_DESIGN.md) | 可解性和关卡原则 |
| [Level 001](docs/LEVEL_001.md) | P0/P1 物理回归关卡 |
| [Level 002](docs/LEVEL_002.md) | P1 机关集成测试 |
| [UI/UX](docs/UI_UX.md) | Android 操作和视觉层级 |
| [Android 构建](docs/BUILD_ANDROID.md) | CI、APK、签名 |
| [开发规范](docs/DEVELOPMENT.md) | 分支、提交、代码规范 |
| [测试计划](docs/TEST_PLAN.md) | P1 功能和 Android 验收 |
| [调试指南](docs/DEBUGGING.md) | 常见问题排查 |
| [路线图](docs/ROADMAP.md) | P0 → P1 → P2 → 在线关卡 |
| [架构决策记录](docs/ADR.md) | 关键技术决策 |
| [发布检查](docs/RELEASE_CHECKLIST.md) | 发布前检查 |
| [变更记录](CHANGELOG.md) | 版本变更 |

## 本地运行

1. 安装 Godot 4.7.x。
2. 导入仓库根目录的 `project.godot`。
3. 运行主场景。
4. 桌面端使用鼠标；Android 使用触摸。

## Android 构建

推荐使用 GitHub Actions。手工构建要求 OpenJDK 17、Android SDK 和 Godot Android export templates。具体步骤见 [Android 构建文档](docs/BUILD_ANDROID.md)。

## 开发原则

1. **先保证物理可解，再做美术。**
2. **目标进入必须立即结束模拟。**
3. **所有关卡必须有明确的可解性验证。**
4. **P1 开始逐步数据驱动。**
5. **手机操作优先于桌面操作。**
6. **新增机关必须有最小可验证关卡。**
7. **不直接复制原游戏代码、素材或受版权保护的关卡数据。**

## 当前已知限制

- 关卡仍直接写在 `main.gd`。
- 组件类型仍通过字符串区分。
- Rope 尚未使用真实物理约束。
- Gear 尚未实现严格齿轮接触求解。
- 没有正式 Level/Save 数据层。
- 没有音频系统、正式编辑器或在线服务。
- 当前 APK 为测试构建，不用于正式商店发布。

## License / IP

实现应保持原创代码和原创/可授权素材。可以研究经典机械解谜游戏的玩法思想，但不得直接复制其代码、素材、商标或受版权保护的关卡内容。正式开源许可证和第三方声明应在公开发行前确定。
