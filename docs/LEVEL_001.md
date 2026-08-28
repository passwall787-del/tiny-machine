# Level 001 — 基础斜坡

- 官方编号：01
- 难度：★1
- 教程：是
- Pattern：`basic`
- 目标：小球进入绿色 Target

## 默认布局
小球起点 + 2 个连续斜坡 + 底部木板。

## 验收
- 可以拖动/旋转斜坡。
- 点击运行后小球沿默认路径运动。
- 进入目标后立即 SUCCESS。
- SUCCESS 后物理停止。

当前具体坐标由 `levels.json` + `LevelData.generate_pattern()` 生成。
