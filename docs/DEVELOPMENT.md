# 开发规范

## 分层
- `main.gd`：UI、状态和玩法编排。
- `level_runtime.gd`：关卡实例生命周期。
- `component_factory.gd`：组件实例化。
- `machine_component.gd`：组件输入、状态和绘制。
- `level_data.gd`：数据模型与序列化。
- `level_validator.gd`：数据校验。
- `audio_manager.gd`：程序化音频。
- `levels.json`：官方关卡目录。

## 修改流程
1. 先修改数据/代码。
2. 更新对应文档。
3. headless 自动测试。
4. Android CI 导出。
5. 真机测试。
6. 发现问题则回到 1，循环直到通过。

## 代码原则
- 不把关卡长期硬编码进 `main.gd`。
- 组件行为尽量通过统一数据接口驱动。
- 物理动态对象优先使用 force/impulse，不在模拟中直接改位置。
- 通关是终端状态，不能继续模拟。
