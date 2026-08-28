# 开发规范

## 1. 分支

推荐：

```text
main
 ├── feature/physics-xxx
 ├── feature/component-xxx
 ├── feature/ui-xxx
 └── fix/xxx
```

`main` 应始终保持可以构建。

## 2. 提交信息

推荐 Conventional Commits 风格：

```text
feat: add spring component
fix: correct slope collision direction
docs: update level design rules
refactor: split level runtime
ci: improve android build
```

## 3. 修改原则

一个提交尽量只解决一个逻辑问题。

例如：

```text
fix: correct level 1 physics
```

不要同时混入几十个无关 UI 修改。

## 4. GDScript 风格

- 使用 4 空格缩进。
- 类型尽可能明确。
- 常量使用大写蛇形命名。
- 函数名使用 `snake_case`。
- 类名使用 PascalCase。
- 避免无意义缩写。
- 关键物理参数必须有注释或文档。

## 5. 节点与资源命名

统一使用英文、语义化名称：

```text
GameRoot
LevelRuntime
TargetArea
Ball
Spring
Gear
```

不要使用：

```text
Node2
Test2
aaa
thing
```

## 6. 新增组件流程

```text
需求定义
 ↓
组件设计文档
 ↓
最小物理实现
 ↓
独立测试
 ↓
与已有组件组合
 ↓
Android 测试
 ↓
加入正式关卡
```

## 7. 修改物理时

修改以下任一内容必须回归测试：

- collision shape
- mass
- gravity
- damping
- physics material
- collision layer/mask
- rotation
- physics timestep

## 8. 修改 UI 时

必须检查：

- 按钮可见性
- 文字对比度
- 点击区域
- 横屏布局
- 不同屏幕比例
- 编辑/运行状态

## 9. 调试日志

开发阶段可以使用日志记录：

- level id
- component id
- goal event
- collision event
- reset event

正式版本必须提供日志等级开关，避免大量输出影响性能。

## 10. 不要过早抽象

P0 可以简单；P1 开始抽象；P2 数据化。

原则：

> 先证明玩法，再抽象架构；但一旦开始批量增加组件，就必须停止继续堆硬编码。
