extends PhysicsBody2D
class_name MachinePiece

var piece_type: String = ""
var main: Node
var dragging := false
var drag_offset := Vector2.ZERO
var start_position := Vector2.ZERO
var start_rotation := 0.0

func setup(p_type: String, owner_main: Node, pos: Vector2, rot: float = 0.0) -> void:
    piece_type = p_type
    main = owner_main
    global_position = pos
    rotation = rot
    start_position = pos
    start_rotation = rot
    input_pickable = true
    queue_redraw()

func _ready() -> void:
    input_pickable = true
    queue_redraw()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
    if main == null or main.running:
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
    if not dragging or main == null or main.running:
        return
    if event is InputEventMouseMotion:
        global_position = get_global_mouse_position() + drag_offset
        main.clamp_piece(self)
    elif event is InputEventScreenDrag:
        global_position = event.position + drag_offset
        main.clamp_piece(self)

func reset_piece() -> void:
    global_position = start_position
    rotation = start_rotation
    if piece_type == "ball":
        set("linear_velocity", Vector2.ZERO)
        set("angular_velocity", 0.0)
        set("sleeping", true)
    queue_redraw()

func _draw() -> void:
    var selected = main != null and main.selected_piece == self and not main.running
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
    if selected:
        var r = 145.0 if piece_type != "ball" else 34.0
        draw_arc(Vector2.ZERO, r, 0, TAU, 64, Color("#72d8ff"), 2.0)
