# Tiny Machine

Tiny Machine 是一个面向 Android 的 2D 物理机关解谜游戏原型，玩法方向参考经典的“机械连锁反应”类游戏：玩家摆放有限的机械组件，启动模拟，让物理系统自行运行，最终完成目标。

> 当前阶段：**P0 原型**。重点不是美术，而是验证“摆放 → 运行 → 物理反应 → 目标判定”的核心循环。

## 当前状态

- Engine: Godot 4.x（CI 当前使用 4.7.2）
- Language: GDScript
- Renderer: GL Compatibility
- Target: Android ARM64（arm64-v8a）
- Current package: `com.passwall.tinymachine`
- Current version: `0.1.0`
- Build type: Debug/test build
- Current level: 1 个可测试原型关卡
- Current components: 小球、木板、斜坡、目标区
- Input: 鼠标 + Android 触摸
- Backend: 无，P0 完全离线

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
机关/物体产生连锁反应
      ↓
目标条件满足？ ── 否 → 失败/继续观察
      │
      是
      ↓
关卡完成
```

## 当前 P0 操作

- 拖动小球、木板、斜坡调整位置。
- 顶部按钮可以添加组件。
- `▶ 开始` 启动物理模拟。
- `⏸ 暂停` 暂停模拟。
- `↻ 重置` 恢复关卡初始状态。
- 小球进入绿色目标区域后判定成功。

## 项目结构

```text
.
├── project.godot              # Godot 项目配置
├── export_presets.cfg         # Android 导出配置
├── main.tscn                  # 主场景
├── main.gd                    # P0 场景、UI、关卡和运行控制
├── piece.gd                   # 机械组件基础类
├── docs/                      # 项目完整文档
├── CHANGELOG.md               # 版本变更记录
├── CONTRIBUTING.md            # 协作规范
└── .github/workflows/         # Android CI 构建
```

## 文档入口

完整文档索引：[docs/INDEX.md](docs/INDEX.md)

| 文档 | 内容 |
|---|---|
| [当前项目状态](docs/PROJECT_STATUS.md) | 当前实现、技术债、下一步和交接信息 |
| [产品与范围](docs/PRODUCT.md) | 产品目标、定位、阶段边界、非目标 |
| [游戏规则](docs/GAMEPLAY.md) | 玩家规则、成功/失败、状态机、输入行为 |
| [架构](docs/ARCHITECTURE.md) | 场景、脚本、数据流、模块边界、未来重构方向 |
| [物理系统](docs/PHYSICS.md) | 刚体、碰撞、重力、稳定性、机关物理原则 |
| [组件规范](docs/COMPONENTS.md) | 组件接口、类型、碰撞体、渲染和未来扩展 |
| [关卡设计](docs/LEVEL_DESIGN.md) | 关卡结构、可解性、验证流程、关卡数据化计划 |
| [UI/UX](docs/UI_UX.md) | 手机交互、按钮、视觉层级、可用性要求 |
| [Android 构建](docs/BUILD_ANDROID.md) | 本地和 GitHub Actions 构建、签名、发布 |
| [开发规范](docs/DEVELOPMENT.md) | 分支、提交、代码风格、测试和调试流程 |
| [测试计划](docs/TEST_PLAN.md) | P0 验收、回归、Android 真机测试清单 |
| [调试指南](docs/DEBUGGING.md) | 物理、UI、触摸、CI 等问题的排查方法 |
| [路线图](docs/ROADMAP.md) | P0 → P1 → 编辑器 → 在线关卡的开发计划 |
| [架构决策记录](docs/ADR.md) | 关键技术决策及原因 |
| [发布检查](docs/RELEASE_CHECKLIST.md) | 发布前功能、物理、Android、签名检查 |
| [变更记录](CHANGELOG.md) | 每个版本的变更摘要 |
| [协作规范](CONTRIBUTING.md) | Bug、PR、开发前后的基本要求 |

## 本地运行

1. 安装 Godot 4.x。
2. 导入仓库根目录的 `project.godot`。
3. 运行主场景。
4. 桌面端使用鼠标测试；Android 使用触摸测试。

## Android 构建

推荐使用仓库中的 GitHub Actions。手工构建要求配置 OpenJDK 17、Android SDK 和 Godot Android export templates。具体步骤见 [Android 构建文档](docs/BUILD_ANDROID.md)。

## 开发原则

1. **先保证物理可解，再做美术。**
2. **所有关卡必须有明确的可解性验证。**
3. **组件逻辑与关卡逻辑分离。**
4. **P0 可以硬编码，P1 开始逐步数据驱动。**
5. **手机操作优先于桌面操作。**
6. **新增机关必须有独立测试场景或最小可验证关卡。**
7. **不直接复制原游戏代码、素材或受版权保护的关卡数据。**

## 当前已知限制

- P0 的关卡仍直接写在 `main.gd` 中。
- 组件类型通过字符串区分，尚未建立正式组件注册系统。
- UI 主要由代码创建，尚未拆分为独立场景。
- 没有独立的 Level/Physics/Save 数据层。
- 没有正式资源管理、音频系统、关卡编辑器或在线服务。
- 当前 APK 是测试签名/Debug 构建，不用于正式商店发布。

## License / IP

当前项目处于原型阶段。实现应保持为原创代码和原创/可授权素材；可以研究经典机械解谜游戏的玩法思想，但不得直接复制其代码、素材、商标或受版权保护的关卡内容。正式开源许可证和第三方声明应在进入公开发行前确定。
