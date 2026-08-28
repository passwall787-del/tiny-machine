extends RefCounted
class_name LevelValidator

const KNOWN_TYPES := {"board":true,"slope":true,"spring":true,"rope":true,"scissors":true,"gear":true,"switch":true,"balloon":true,"magnet":true,"bomb":true}
const BOUNDS := Rect2(45, 112, 1190, 410)

static func validate(level: LevelData) -> Dictionary:
    var errors: Array[String] = []
    var warnings: Array[String] = []
    var counts: Dictionary = {}

    if level.goal_radius <= 0.0:
        errors.append("目标半径必须大于 0")
    if not BOUNDS.has_point(level.goal_position):
        errors.append("目标区域超出编辑边界")
    if not BOUNDS.has_point(level.start_position):
        errors.append("小球起点超出编辑边界")

    for kind in level.inventory:
        var amount := int(level.inventory[kind])
        if not KNOWN_TYPES.has(str(kind)):
            errors.append("库存存在未知组件：%s" % str(kind))
        if amount < 0:
            errors.append("组件 %s 的库存不能为负数" % str(kind))

    for p in level.pieces:
        var kind := str(p.get("type", ""))
        if not KNOWN_TYPES.has(kind):
            errors.append("未知组件：%s" % kind)
        counts[kind] = int(counts.get(kind, 0)) + 1
        var x := float(p.get("x", 0))
        var y := float(p.get("y", 0))
        if not BOUNDS.has_point(Vector2(x, y)):
            errors.append("组件 %s 超出编辑边界" % kind)
        if not is_finite(x) or not is_finite(y):
            errors.append("组件 %s 坐标不是有限数值" % kind)

    for kind in counts:
        var placed := int(counts[kind])
        var allowed := int(level.inventory.get(kind, 0))
        if placed > allowed:
            errors.append("组件 %s 放置数量 %d 超过库存 %d" % [kind, placed, allowed])

    if level.pieces.size() > 60:
        warnings.append("组件数量超过 60，移动端性能需要真机验证")
    if level.pieces.is_empty():
        warnings.append("当前为施工初始状态：尚未放置任何零件")

    return {"ok":errors.is_empty(),"errors":errors,"warnings":warnings}
