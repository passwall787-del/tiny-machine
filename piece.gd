extends PhysicsBody2D
class_name MachinePiece

var piece_type: String = ""
var main: Node
var dragging := false
var drag_offset := Vector2.ZERO
var start_position := Vector2.ZERO
var start_rotation := 0.0
var active := false
var triggered := false
var cut := false
var simulation_enabled := false
var spin_speed := 2.8

func setup(p_type: String, owner_main: Node, pos: Vector2, rot: float = 0.0) -> void:
    piece_type = p_type
    main = owner_main
    global_position = pos
    rotation = rot
    start_position = pos
    start_rotation = rot
    input_pickable = true
    simulation_enabled = false
    queue_redraw()

func _ready() -> void:
    input_pickable = true
    queue_redraw()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
    if main == null or not main.is_in_group("game_root") and main.game_state != main.GameState.EDITING:
        return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            dragging = true
            drag_offset = global_position - get_global_mouse_position()
            main.select_piece(self)
        else:
            dragging = false
    elif event is InputEventScreenTouch:
        if event.pressed:
            dragging = true
            drag_offset = global_position - event.position
            main.select_piece(self)
        else:
            dragging = false

func _input(event: InputEvent) -> void:
    if not dragging or main == null or main.game_state != main.GameState.EDITING:
        return
    if event is InputEventMouseMotion:
        global_position = get_global_mouse_position() + drag_offset
        main.clamp_piece(self)
    elif event is InputEventScreenDrag:
        global_position = event.position + drag_offset
        main.clamp_piece(self)

func _physics_process(delta: float) -> void:
    if main == null or not simulation_enabled:
        return
    if piece_type == "balloon" and self is RigidBody2D:
        (self as RigidBody2D).apply_central_force(Vector2(0, -95.0))
    elif piece_type == "gear":
        rotation += spin_speed * delta if active else 0.0
        queue_redraw()

func reset_piece() -> void:
    global_position = start_position
    rotation = start_rotation
    active = false
    triggered = false
    cut = false
    simulation_enabled = false
    dragging = false
    if self is RigidBody2D:
        var rb := self as RigidBody2D
        rb.freeze = true
        rb.linear_velocity = Vector2.ZERO
        rb.angular_velocity = 0.0
        rb.sleeping = true
    queue_redraw()

func cut_rope() -> void:
    if piece_type != "rope":
        return
    cut = true
    triggered = true
    queue_redraw()

func _draw() -> void:
    var selected = main != null and main.selected_piece == self and main.game_state == main.GameState.EDITING
    var outline_width = 5.0 if selected else 3.0

    if piece_type == "ball":
        draw_circle(Vector2.ZERO, 24.0, Color("#e7edf5"))
        draw_circle(Vector2.ZERO, 18.0, Color("#8bc6ff"))
        draw_circle(Vector2(-6, -7), 5.0, Color(1, 1, 1, 0.55))
        draw_arc(Vector2.ZERO, 24.0, 0, TAU, 48, Color("#243041"), outline_width)
    elif piece_type == "board":
        var rect = Rect2(-125, -15, 250, 30)
        draw_rect(rect, Color("#c88a4a"), true)
        draw_rect(rect, Color("#5c3b22"), false, outline_width)
        for x in range(-100, 101, 50):
            draw_line(Vector2(x, -12), Vector2(x + 10, 12), Color(0.35, 0.20, 0.10, 0.35), 2)
    elif piece_type == "slope":
        var poly = PackedVector2Array([Vector2(-125, 22), Vector2(125, -22), Vector2(125, 22)])
        draw_colored_polygon(poly, Color("#d39a58"))
        draw_polyline(PackedVector2Array([Vector2(-125, 22), Vector2(125, -22), Vector2(125, 22), Vector2(-125, 22)]), Color("#5c3b22"), outline_width, true)
        draw_line(Vector2(-90, 14), Vector2(80, -14), Color(1, 1, 1, 0.12), 3)
    elif piece_type == "spring":
        var base = Color("#45a4ff") if active else Color("#536a85")
        draw_rect(Rect2(-55, -13, 110, 26), base, true)
        draw_rect(Rect2(-55, -13, 110, 26), Color("#d9e8f7"), false, outline_width)
        var points := PackedVector2Array()
        for i in range(9):
            var px = -40.0 + i * 10.0
            var py = -7.0 if i % 2 == 0 else 7.0
            points.append(Vector2(px, py))
        draw_polyline(points, Color("#f1f6fb"), 3.0, true)
        draw_line(Vector2(15, 0), Vector2(48, 0), Color("#ffffff"), 3)
        draw_line(Vector2(48, 0), Vector2(38, -7), Color("#ffffff"), 3)
        draw_line(Vector2(48, 0), Vector2(38, 7), Color("#ffffff"), 3)
    elif piece_type == "rope":
        var rope_color = Color("#f1b84b") if not cut else Color("#9b4d4d")
        if not cut:
            draw_line(Vector2(-90, 0), Vector2(90, 0), rope_color, 8, true)
        else:
            draw_line(Vector2(-90, 0), Vector2(-14, 0), rope_color, 8, true)
            draw_line(Vector2(14, 0), Vector2(90, 0), rope_color, 8, true)
            draw_circle(Vector2.ZERO, 10, Color("#e85d5d"))
        draw_circle(Vector2(-90, 0), 8, Color("#c8d4e0"))
        draw_circle(Vector2(90, 0), 8, Color("#c8d4e0"))
    elif piece_type == "scissors":
        var blade = Color("#d9e3ee")
        draw_line(Vector2(-34, -11), Vector2(34, 11), blade, 7, true)
        draw_line(Vector2(-34, 11), Vector2(34, -11), blade, 7, true)
        draw_circle(Vector2(-32, -14), 12, Color("#e17b6c"), false, 4)
        draw_circle(Vector2(-32, 14), 12, Color("#e17b6c"), false, 4)
        draw_circle(Vector2(0, 0), 5, Color("#ffffff"))
        if triggered:
            draw_arc(Vector2.ZERO, 50, -0.4, 0.4, 20, Color("#ff6f61"), 4)
    elif piece_type == "gear":
        var gear_color = Color("#6f91b6") if not active else Color("#4da7ff")
        draw_circle(Vector2.ZERO, 38, gear_color)
        for i in range(12):
            var a = TAU * float(i) / 12.0
            var inner = Vector2.RIGHT.rotated(a) * 34.0
            var outer = Vector2.RIGHT.rotated(a) * 48.0
            draw_line(inner, outer, gear_color, 9, true)
        draw_circle(Vector2.ZERO, 12, Color("#172131"))
        draw_circle(Vector2.ZERO, 5, Color("#dce8f5"))
        if active:
            draw_arc(Vector2.ZERO, 54, 0, TAU, 48, Color("#8fd2ff"), 2)
    elif piece_type == "switch":
        var plate = Color("#4bd58a") if active else Color("#68768a")
        draw_rect(Rect2(-55, -14, 110, 28), plate, true)
        draw_rect(Rect2(-55, -14, 110, 28), Color("#e6eef6"), false, outline_width)
        draw_circle(Vector2(0, 0), 8, Color("#ffffff") if active else Color("#c5cfdb"))
        draw_string(ThemeDB.fallback_font, Vector2(-25, -22), "ON" if active else "OFF", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#ffffff"))
    elif piece_type == "balloon":
        var balloon_color = Color("#ff8a9a")
        draw_circle(Vector2.ZERO, 28, balloon_color)
        draw_circle(Vector2(-8, -9), 7, Color(1, 1, 1, 0.28))
        draw_line(Vector2(0, 28), Vector2(0, 58), Color("#d9e0e8"), 2)
        draw_colored_polygon(PackedVector2Array([Vector2(-5, 24), Vector2(0, 34), Vector2(5, 24)]), balloon_color)

    if selected:
        var r = 145.0 if piece_type == "board" or piece_type == "slope" else 58.0
        draw_arc(Vector2.ZERO, r, 0, TAU, 64, Color("#72d8ff"), 2.0)
