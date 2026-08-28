# Tiny Machine

移动端 2D 物理机关解谜游戏原型。

## 当前版本

**P3 首轮交付**：P2 关卡编辑器 + P3 32 个官方关卡与基础体验系统。

### 已有能力
- 小球、木板、斜坡
- Spring / Switch / Gear
- Rope / Scissors / Balloon
- Magnet / Bomb
- 目标进入立即结束模拟
- 失败：掉出场地 / 18 秒超时
- 拖动、旋转、多选、删除
- 撤销 / 重做
- 20px 网格吸附
- 本机保存 / 加载自制关卡
- 关卡验证器
- 32 个官方关卡
- 1~5 教程
- 1~8 星难度
- 成功/失败动画
- 程序化音效与轻量 BGM

## 技术
- Godot 4.7.2
- Android ARM64
- GL Compatibility
- GitHub Actions 自动测试与 APK 导出

## 开发入口
先阅读：
1. `docs/PROJECT_STATUS.md`
2. `docs/ROADMAP.md`
3. `docs/ARCHITECTURE.md`
4. `docs/TEST_PLAN.md`

## 原则
先验证物理和关卡可解性，再做在线功能和商业化。玩法参考经典机械连锁解谜思路，但代码、素材和关卡数据保持原创。
