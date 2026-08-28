extends Node2D
class_name MachineComponent

var piece_type: String = ""
var owner_main: Node
var editor: Node
var start_position := Vector2.ZERO
var start_rotation := 0.0
var dragging := false
var drag_offset := Vector2.ZERO
var simulation_enabled := false
var active := false
var triggered := false
var cut := false
var spent := false
var editable := true
var spin_speed := 2.8

func setup(kind: String, owner: Node, editor_node: Node, pos: Vector2, rot: float) -> void:
    piece_type = kind
    owner_main = owner
    editor = editor_node
    global_position = pos
    rotation = rot
    start_position = pos
    start_rotation = rot
    var node: Node = self
    if node is CollisionObject2D:
        var collider: CollisionObject2D = node
        collider.input_pickable = editable
    queue_redraw()

func _ready() -> void:
    var node: Node = self
    if node is CollisionObject2D:
        var collider: CollisionObject2D = node
        collider.input_pickable = editable
    queue_redraw()

func _is_editing() -> bool:
    return editable and editor != null and editor.has_method("is_editing") and editor.is_editing()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
    if not _is_editing(): return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            dragging = true
            drag_offset = global_position - get_global_mouse_position()
            editor.on_piece_pressed(self)
        else:
            dragging = false
            editor.on_piece_released(self)
    elif event is InputEventScreenTouch:
        if event.pressed:
            dragging = true
            drag_offset = global_position - event.position
            editor.on_piece_pressed(self)
        else:
            dragging = false
            editor.on_piece_released(self)

func _input(event: InputEvent) -> void:
    if not dragging or not _is_editing(): return
    if event is InputEventMouseMotion:
        editor.drag_piece_to(self, get_global_mouse_position() + drag_offset)
    elif event is InputEventScreenDrag:
        editor.drag_piece_to(self, event.position + drag_offset)

func set_simulation(enabled: bool) -> void:
    simulation_enabled = enabled
    var node: Node = self
    if node is RigidBody2D:
        var rb: RigidBody2D = node
        rb.freeze = not enabled
        if enabled: rb.sleeping = false

func reset_runtime() -> void:
    global_position = start_position
    rotation = start_rotation
    simulation_enabled = false
    active = false
    triggered = false
    cut = false
    spent = false
    dragging = false
    var node: Node = self
    if node is RigidBody2D:
        var rb: RigidBody2D = node
        rb.freeze = true
        rb.linear_velocity = Vector2.ZERO
        rb.angular_velocity = 0.0
        rb.sleeping = true
    queue_redraw()

func apply_impulse(impulse: Vector2) -> void:
    var node: Node = self
    if node is RigidBody2D:
        var rb: RigidBody2D = node
        rb.apply_central_impulse(impulse)

func cut_rope() -> void:
    if piece_type == "rope":
        cut = true
        triggered = true
        queue_redraw()

func _physics_process(delta: float) -> void:
    if not simulation_enabled: return
    var node: Node = self
    if piece_type == "balloon" and node is RigidBody2D:
        var rb: RigidBody2D = node
        rb.apply_central_force(Vector2(0, -95.0))
    elif piece_type == "gear" and active:
        rotation += spin_speed * delta
        queue_redraw()

func _draw() -> void:
    var selected := false
    if editor != null and editor.has_method("is_piece_selected"):
        selected = bool(editor.is_piece_selected(self)) and _is_editing()
    var outline := Color("#6ed5ff") if selected else Color("#25374a")
    var shadow := Color(0, 0, 0, 0.22)

    match piece_type:
        "ball":
            draw_circle(Vector2(3, 5), 25, shadow)
            draw_circle(Vector2.ZERO, 25, Color("#f4f7fb"))
            draw_circle(Vector2.ZERO, 20, Color("#5ba9ff"))
            draw_circle(Vector2(-7, -8), 6, Color(1, 1, 1, 0.65))
            draw_arc(Vector2.ZERO, 25, 0, TAU, 48, outline, 3)
            draw_arc(Vector2.ZERO, 19, 0.35, 2.5, 32, Color("#c8e5ff"), 2)
        "board":
            var rect := Rect2(-128, -16, 256, 32)
            draw_rect(Rect2(rect.position + Vector2(4, 5), rect.size), shadow, true)
            draw_rect(rect, Color("#b8753c"), true)
            draw_rect(Rect2(-128, -16, 256, 8), Color("#e0a05d"), true)
            for x in range(-110, 111, 44): draw_line(Vector2(x, -7), Vector2(x + 10, 10), Color("#8d552f"), 2)
            draw_rect(rect, outline, false, 3)
            draw_circle(Vector2(-112, 0), 3, Color("#e8c18e"))
            draw_circle(Vector2(112, 0), 3, Color("#e8c18e"))
        "slope":
            var poly := PackedVector2Array([Vector2(-128, 15), Vector2(128, -18), Vector2(128, 15)])
            draw_colored_polygon(PackedVector2Array([Vector2(-124, 20),Vector2(124,-13),Vector2(124,20)]), shadow)
            draw_colored_polygon(poly, Color("#c98948"))
            draw_polyline(poly, outline, 3, true)
            draw_line(Vector2(-110, 5), Vector2(110, -13), Color("#f1c27e"), 4, true)
            for x in range(-100, 101, 40): draw_line(Vector2(x, 7 - (x + 110) * 0.13), Vector2(x + 16, 12 - (x + 110) * 0.13), Color("#9d5f32"), 2)
        "spring":
            var base := Color("#3f9dff") if active else Color("#59708a")
            draw_rect(Rect2(-58, -16, 116, 32), shadow, true)
            draw_rect(Rect2(-58, -16, 116, 32), Color("#25364b"), true)
            draw_rect(Rect2(-54, -12, 108, 24), base, true)
            var points := PackedVector2Array()
            for i in range(9):
                var px := -42.0 + float(i) * 10.5
                var py := -7.0 if i % 2 == 0 else 7.0
                points.append(Vector2(px, py))
            draw_polyline(points, Color("#f3f8ff"), 3, true)
            draw_line(Vector2(32, 0), Vector2(48, 0), Color("#f3f8ff"), 3)
            draw_line(Vector2(48, 0), Vector2(39, -7), Color("#f3f8ff"), 3)
            draw_line(Vector2(48, 0), Vector2(39, 7), Color("#f3f8ff"), 3)
        "rope":
            var rope_color := Color("#e5a53f") if not cut else Color("#92565a")
            if not cut:
                draw_line(Vector2(-92, 0), Vector2(92, 0), shadow, 10, true)
                draw_line(Vector2(-92, 0), Vector2(92, 0), rope_color, 7, true)
                for x in range(-80, 81, 24): draw_arc(Vector2(x, 0), 7, 0, PI, 8, Color("#f7ca70"), 2)
            else:
                draw_line(Vector2(-92, 0), Vector2(-16, 0), rope_color, 7, true)
                draw_line(Vector2(16, 0), Vector2(92, 0), rope_color, 7, true)
                draw_circle(Vector2.ZERO, 9, Color("#ef6868"))
        "scissors":
            draw_circle(Vector2(-31, -14), 14, Color("#e77e72"), false, 5)
            draw_circle(Vector2(-31, 14), 14, Color("#e77e72"), false, 5)
            draw_line(Vector2(-22, -9), Vector2(40, 17), Color("#dfe9f4"), 7, true)
            draw_line(Vector2(-22, 9), Vector2(40, -17), Color("#dfe9f4"), 7, true)
            draw_line(Vector2(40, 17), Vector2(23, 11), Color("#91a6bb"), 2)
            draw_line(Vector2(40, -17), Vector2(23, -11), Color("#91a6bb"), 2)
            if triggered: draw_arc(Vector2(15, 0), 34, -0.55, 0.55, 20, Color("#ff7066"), 4)
        "gear":
            var gear_color := Color("#4fa9ff") if active else Color("#6f8ca8")
            draw_circle(Vector2(3, 4), 42, shadow)
            for i in range(12):
                var a := TAU * float(i) / 12.0
                draw_line(Vector2.RIGHT.rotated(a) * 34, Vector2.RIGHT.rotated(a) * 49, gear_color, 10, true)
            draw_circle(Vector2.ZERO, 39, gear_color)
            draw_circle(Vector2.ZERO, 14, Color("#172434"))
            draw_circle(Vector2.ZERO, 6, Color("#e6f0fb"))
            draw_arc(Vector2.ZERO, 28, -1.8, 0.2, 24, Color(1, 1, 1, 0.28), 3)
        "switch":
            var switch_color := Color("#49d88a") if active else Color("#718097")
            draw_rect(Rect2(-59, -18, 118, 36), shadow, true)
            draw_rect(Rect2(-59, -18, 118, 36), Color("#243447"), true)
            draw_rect(Rect2(-54, -13, 108, 26), switch_color, true)
            draw_circle(Vector2(34, 0), 9, Color("#effff5") if active else Color("#b7c3d0"))
            draw_line(Vector2(-15, 0), Vector2(12, -14 if not active else 14), Color("#f5f8fb"), 5, true)
            draw_string(ThemeDB.fallback_font, Vector2(-43, 5), "ON" if active else "OFF", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#10202e"))
        "balloon":
            draw_line(Vector2(0, 28), Vector2(0, 68), Color("#dce5ef"), 2)
            draw_circle(Vector2(0, 2), 30, shadow)
            draw_circle(Vector2.ZERO, 30, Color("#ff748e"))
            draw_circle(Vector2(-9, -10), 8, Color(1, 1, 1, 0.28))
            draw_circle(Vector2(0, 31), 4, Color("#e45b78"))
        "magnet":
            var red := Color("#ef6273") if active else Color("#9a6570")
            var blue := Color("#5ca8ff")
            draw_arc(Vector2.ZERO, 38, PI, TAU, 28, red, 11)
            draw_line(Vector2(-38, 0), Vector2(-38, -22), red, 11, true)
            draw_line(Vector2(38, 0), Vector2(38, -22), blue, 11, true)
            draw_circle(Vector2(-38, -22), 6, Color("#f5f7fa"))
            draw_circle(Vector2(38, -22), 6, Color("#f5f7fa"))
            if active: draw_arc(Vector2.ZERO, 60, 0, TAU, 48, Color(0.95,0.35,0.45,0.14), 3)
        "bomb":
            var bomb_color := Color("#e45b5b") if not spent else Color("#6d7784")
            draw_circle(Vector2(3, 5), 31, shadow)
            draw_circle(Vector2.ZERO, 31, bomb_color)
            draw_circle(Vector2(-8, -10), 7, Color(1, 1, 1, 0.2))
            draw_line(Vector2(12, -24), Vector2(29, -41), Color("#e9d39c"), 6, true)
            draw_circle(Vector2(32, -44), 7, Color("#ffd96c"))
            draw_circle(Vector2(32, -44), 3, Color("#fff3c2"))

    if selected:
        var radius := 142.0 if piece_type in ["board", "slope"] else 62.0
        draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color("#69d8ff"), 3)
        draw_circle(Vector2(0, -radius), 6, Color("#69d8ff"))
