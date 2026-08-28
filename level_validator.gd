extends RefCounted
class_name LevelValidator

const KNOWN_TYPES := {"ball":true,"board":true,"slope":true,"spring":true,"rope":true,"scissors":true,"gear":true,"switch":true,"balloon":true,"magnet":true,"bomb":true}
const BOUNDS := Rect2(45, 175, 1190, 495)

static func validate(level: LevelData) -> Dictionary:
    var errors: Array[String] = []
    var warnings: Array[String] = []
    var ball_count := 0
    if level.goal_radius <= 0.0:
        errors.append("目标半径必须大于 0")
    if not BOUNDS.has_point(level.goal_position):
        errors.append("目标区域超出编辑边界")
    for p in level.pieces:
        var kind := str(p.get("type", ""))
        if not KNOWN_TYPES.has(kind):
            errors.append("未知组件：%s" % kind)
        if kind == "ball":
            ball_count += 1
        var x := float(p.get("x", 0))
        var y := float(p.get("y", 0))
        if not BOUNDS.has_point(Vector2(x, y)):
            errors.append("组件 %s 超出编辑边界" % kind)
        if not is_finite(x) or not is_finite(y):
            errors.append("组件 %s 坐标不是有限数值" % kind)
    if ball_count == 0:
        errors.append("缺少小球")
    elif ball_count > 1:
        warnings.append("存在多个小球；当前规则只认第一个小球为目标对象")
    if level.pieces.size() > 60:
        warnings.append("组件数量超过 60，移动端性能需要真机验证")
    return {"ok":errors.is_empty(),"errors":errors,"warnings":warnings}
