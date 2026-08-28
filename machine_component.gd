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
        collider.input_pickable = true
    queue_redraw()

func _ready() -> void:
    var node: Node = self
    if node is CollisionObject2D:
        var collider: CollisionObject2D = node
        collider.input_pickable = true
    queue_redraw()

func _is_editing() -> bool:
    return editor != null and editor.has_method("is_editing") and editor.is_editing()

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
    var selected: bool = false
    if editor != null and editor.has_method("is_piece_selected"):
        selected = bool(editor.is_piece_selected(self)) and _is_editing()
    var outline := 5.0 if selected else 3.0
    match piece_type:
        "ball":
            draw_circle(Vector2.ZERO, 24.0, Color("#e7edf5"))
            draw_circle(Vector2.ZERO, 18.0, Color("#70b8ff"))
            draw_circle(Vector2(-6, -7), 5.0, Color(1, 1, 1, 0.55))
            draw_arc(Vector2.ZERO, 24.0, 0, TAU, 48, Color("#243041"), outline)
        "board":
            var rect := Rect2(-125, -15, 250, 30)
            draw_rect(rect, Color("#c88a4a"), true)
            draw_rect(rect, Color("#5c3b22"), false, outline)
        "slope":
            var poly := PackedVector2Array([Vector2(-125, 22), Vector2(125, -22), Vector2(125, 22)])
            draw_colored_polygon(poly, Color("#d39a58"))
            draw_polyline(PackedVector2Array([poly[0], poly[1], poly[2], poly[0]]), Color("#5c3b22"), outline, true)
        "spring":
            var spring_color := Color("#45a4ff") if active else Color("#536a85")
            draw_rect(Rect2(-55, -13, 110, 26), spring_color, true)
            draw_rect(Rect2(-55, -13, 110, 26), Color("#d9e8f7"), false, outline)
            draw_line(Vector2(15, 0), Vector2(48, 0), Color.WHITE, 3)
            draw_line(Vector2(48, 0), Vector2(38, -7), Color.WHITE, 3)
            draw_line(Vector2(48, 0), Vector2(38, 7), Color.WHITE, 3)
        "rope":
            var rope_color := Color("#f1b84b") if not cut else Color("#9b4d4d")
            if not cut:
                draw_line(Vector2(-90, 0), Vector2(90, 0), rope_color, 8, true)
            else:
                draw_line(Vector2(-90, 0), Vector2(-14, 0), rope_color, 8, true)
                draw_line(Vector2(14, 0), Vector2(90, 0), rope_color, 8, true)
                draw_circle(Vector2.ZERO, 10, Color("#e85d5d"))
        "scissors":
            draw_line(Vector2(-34, -11), Vector2(34, 11), Color("#d9e3ee"), 7, true)
            draw_line(Vector2(-34, 11), Vector2(34, -11), Color("#d9e3ee"), 7, true)
            draw_circle(Vector2(-32, -14), 12, Color("#e17b6c"), false, 4)
            draw_circle(Vector2(-32, 14), 12, Color("#e17b6c"), false, 4)
            if triggered: draw_arc(Vector2.ZERO, 50, -0.4, 0.4, 20, Color("#ff6f61"), 4)
        "gear":
            var gear_color := Color("#4da7ff") if active else Color("#6f91b6")
            draw_circle(Vector2.ZERO, 38, gear_color)
            for i in range(12):
                var angle := TAU * float(i) / 12.0
                draw_line(Vector2.RIGHT.rotated(angle) * 34.0, Vector2.RIGHT.rotated(angle) * 48.0, gear_color, 9, true)
            draw_circle(Vector2.ZERO, 12, Color("#172131"))
            draw_circle(Vector2.ZERO, 5, Color("#dce8f5"))
        "switch":
            var switch_color := Color("#4bd58a") if active else Color("#68768a")
            draw_rect(Rect2(-55, -14, 110, 28), switch_color, true)
            draw_rect(Rect2(-55, -14, 110, 28), Color("#e6eef6"), false, outline)
            draw_string(ThemeDB.fallback_font, Vector2(-17, 5), "ON" if active else "OFF", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
        "balloon":
            draw_circle(Vector2.ZERO, 28, Color("#ff8a9a"))
            draw_circle(Vector2(-8, -9), 7, Color(1, 1, 1, 0.28))
            draw_line(Vector2(0, 28), Vector2(0, 58), Color("#d9e0e8"), 2)
        "magnet":
            var magnet_color := Color("#ff6878") if active else Color("#7f8794")
            draw_arc(Vector2.ZERO, 34, 0, PI, 24, magnet_color, 10)
            draw_line(Vector2(-34, 0), Vector2(-34, -20), magnet_color, 10)
            draw_line(Vector2(34, 0), Vector2(34, -20), Color("#65aaff"), 10)
            draw_arc(Vector2.ZERO, 60, 0, TAU, 40, Color(1, 0.4, 0.5, 0.16), 2)
        "bomb":
            var bomb_color := Color("#e65c5c") if not spent else Color("#5b6572")
            draw_circle(Vector2.ZERO, 30, bomb_color)
            draw_line(Vector2(12, -24), Vector2(26, -38), Color("#e9d49a"), 6)
            draw_circle(Vector2(28, -40), 6, Color("#ffd66b"))
    if selected:
        var radius := 145.0 if piece_type in ["board", "slope"] else 58.0
        draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color("#72d8ff"), 2)
