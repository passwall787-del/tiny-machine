# 文档索引

## 推荐阅读顺序

第一次接手项目：

1. `PROJECT_STATUS.md` — 当前做到哪里、下一步做什么。
2. `PRODUCT.md` — 为什么做、做到什么程度。
3. `GAMEPLAY.md` — 游戏规则。
4. `ARCHITECTURE.md` — 代码如何组织。
5. `PHYSICS.md` — 物理系统注意事项。
6. `COMPONENTS.md` — 机关如何设计。
7. `LEVEL_DESIGN.md` — 关卡如何设计和验证。
8. `UI_UX.md` — 手机交互规则。
9. `DEVELOPMENT.md` — 日常开发规范。
10. `TEST_PLAN.md` — 修改后如何验证。
11. `BUILD_ANDROID.md` — 如何构建 APK。
12. `ROADMAP.md` — 后续计划。
13. `ADR.md` — 已经做过哪些关键技术决策。
14. `DEBUGGING.md` — 出问题怎么排查。
15. `RELEASE_CHECKLIST.md` — 发布前检查。

## 文档维护规则

任何以下改动都必须同步文档：

- 新增组件 → `COMPONENTS.md`
- 修改物理规则 → `PHYSICS.md`
- 修改关卡 → `LEVEL_DESIGN.md`
- 修改玩家规则 → `GAMEPLAY.md`
- 修改架构 → `ARCHITECTURE.md` + `ADR.md`
- 修改发布流程 → `BUILD_ANDROID.md`
- 完成/取消路线图项目 → `ROADMAP.md`
- 用户可见功能变化 → `CHANGELOG.md`

## 文档原则

文档描述“当前真实状态”，不要把计划写成已经实现。

如果计划与代码不一致，以代码和实际测试结果为准，然后立即修正文档。
