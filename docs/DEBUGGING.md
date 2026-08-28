# 调试与故障排查

## 1. 游戏无法启动

检查：

1. Godot 版本是否与项目兼容。
2. `project.godot` 是否完整。
3. 主场景是否为 `main.tscn`。
4. GDScript 是否有语法错误。
5. Android APK 是否为当前 commit 构建。

## 2. 小球不动

按顺序检查：

- 是否点击了开始。
- `running` 是否为 true。
- `ball.freeze` 是否为 false。
- `gravity_scale` 是否为 1。
- 小球是否已经 sleeping。
- 碰撞体是否存在。
- 物理世界边界是否正确。

## 3. 小球穿透机关

检查：

- CollisionShape2D / CollisionPolygon2D。
- collision layer/mask。
- 物体速度是否过高。
- 碰撞体是否过薄。
- 是否在错误的物理回调里修改位置。

## 4. 小球卡住

检查：

- 两个碰撞体是否形成尖角。
- 摩擦是否过高。
- damping 是否过高。
- 是否发生多物体堆叠。
- reset 后速度是否清零。

## 5. 第一关失败

首先不要调随机参数。检查关卡几何：

```text
Ball
 ↓
Slope 1
 ↓
Slope 2
 ↓
Slope 3
 ↓
Board
 ↓
Target
```

确认每个组件的视觉表面、碰撞表面和旋转方向一致。

## 6. 触摸拖动异常

检查：

- `input_pickable`。
- `InputEventScreenTouch`。
- `InputEventScreenDrag`。
- viewport 的坐标系。
- UI 是否拦截触摸。
- 设备是否存在缩放/安全区偏移。

## 7. 按钮看不见

检查 UI 对比度：

- background
- normal
- hover
- pressed
- disabled
- font color

不要只改变文字颜色；按钮背景和边框也必须有足够差异。

## 8. Reset 后行为不同

检查组件是否保存并恢复：

- position
- rotation
- velocity
- angular velocity
- sleeping
- freeze
- internal state

## 9. CI 构建失败

先查看：

```text
Set up job
Checkout
Build with Godot CI Docker image
```

如果失败发生在 Build 步骤，重点检查：

- Godot CI 镜像版本。
- export templates。
- Android preset 名称。
- project.godot。
- export_presets.cfg。

如果 APK 已生成但 Release 失败，不要重复编译；先检查上传步骤。

## 10. 调试原则

一次只改变一个变量。

物理问题优先使用最小测试场景复现，不要直接在复杂关卡里盲目调参数。
