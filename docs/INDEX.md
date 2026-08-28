# 文档索引

## 推荐阅读顺序

第一次接手项目：

1. `PROJECT_STATUS.md` — 当前阶段、已实现和下一步。
2. `PRODUCT.md` — 为什么做、做到什么程度。
3. `GAMEPLAY.md` — 游戏规则和终端通关状态。
4. `ARCHITECTURE.md` — 代码如何组织。
5. `PHYSICS.md` — 物理系统和机关触发。
6. `COMPONENTS.md` — P1 机关规范。
7. `LEVEL_DESIGN.md` — 关卡如何设计和验证。
8. `LEVEL_001.md` — 基础物理回归关卡。
9. `LEVEL_002.md` — P1 机关集成测试关卡。
10. `UI_UX.md` — Android 交互规则。
11. `DEVELOPMENT.md` — 日常开发规范。
12. `TEST_PLAN.md` — 修改后如何验证。
13. `DEBUGGING.md` — 物理、UI、触摸和 CI 排查。
14. `BUILD_ANDROID.md` — 如何构建 APK。
15. `ROADMAP.md` — 后续计划。
16. `ADR.md` — 关键技术决策。
17. `RELEASE_CHECKLIST.md` — 发布前检查。

## 文档维护规则

以下改动必须同步文档：

- 新增组件 → `COMPONENTS.md`
- 修改物理规则 → `PHYSICS.md`
- 修改关卡 → `LEVEL_DESIGN.md` + 对应 `LEVEL_xxx.md`
- 修改玩家规则 → `GAMEPLAY.md`
- 修改架构 → `ARCHITECTURE.md` + `ADR.md`
- 修改 Android 构建 → `BUILD_ANDROID.md`
- 完成/取消路线图项目 → `ROADMAP.md`
- 用户可见功能变化 → `CHANGELOG.md`
- 修复历史问题 → `PROJECT_STATUS.md` 或对应专题文档

## 文档原则

文档必须描述“当前真实状态”，不要把计划写成已经实现。

如果计划与代码不一致，以代码和实际测试结果为准，然后立即修正文档。

每个新机制都应该同时回答：

1. 玩家怎么使用？
2. 物理上怎么工作？
3. 如何重置？
4. 如何测试？
5. 如何在 Android 真机验证？
