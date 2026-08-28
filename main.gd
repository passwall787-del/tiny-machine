extends Node2D

var running := false
var won := false
var selected_piece: MachinePiece = null
var pieces: Array[MachinePiece] = []
var ball: MachinePiece
var target: Area2D
var status_label: Label
var hint_label: Label
var run_button: Button
var palette_buttons: Array[Button] = []

const BOARD_BOUNDS := Rect2(20, 105, 1240, 585)
const TARGET_POS := Vector2(1110, 605)

func _ready() -> void:
    get_viewport().physics_object_picking_sort = true
    _build_ui()
    _build_level()
    queue_redraw()

func _make_style(bg: Color, border: Color, radius: int = 10, border_width: int = 1) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.set_border_width_all(border_width)
    s.set_corner_radius_all(radius)
    s.content_margin_left = 12
    s.content_margin_right = 12
    s.content_margin_top = 8
    s.content_margin_bottom = 8
    return s

func _style_button(button: Button, accent := false) -> void:
    var normal = _make_style(Color("#253246") if not accent else Color("#1f8cff"), Color("#40536d") if not accent else Color("#70c0ff"), 10, 1)
    var hover = _make_style(Color("#31435b") if not accent else Color("#3ca2ff"), Color("#6b86a8") if not accent else Color("#b8e2ff"), 10, 1)
    var pressed = _make_style(Color("#1c2737") if not accent else Color("#176dc7"), Color("#80a6d2") if not accent else Color("#d8efff"), 10, 2)
    var disabled = _make_style(Color("#1a212c"), Color("#2a3544"), 10, 1)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("focus", hover)
    button.add_theme_stylebox_override("disabled", disabled)
    button.add_theme_color_override("font_color", Color("#f5f8fc"))
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    button.add_theme_color_override("font_pressed_color", Color.WHITE)
    button.add_theme_color_override("font_disabled_color", Color("#718096"))

func _build_ui() -> void:
    var layer = CanvasLayer.new()
    layer.name = "UI"
    add_child(layer)

    var top = Panel.new()
    top.position = Vector2(0, 0)
    top.size = Vector2(1280, 88)
    top.add_theme_stylebox_override("panel", _make_style(Color("#0b1018"), Color("#263348"), 0, 0))
    layer.add_child(top)

    var title = Label.new()
    title.text = "TINY MACHINE  ·  P0"
    title.position = Vector2(28, 12)
    title.add_theme_font_size_override("font_size", 24)
    title.add_theme_color_override("font_color", Color("#f2f6fb"))
    top.add_child(title)

    hint_label = Label.new()
    hint_label.text = "编辑模式：拖动机关摆放位置  ·  目标：让小球沿机关进入绿色目标区"
    hint_label.position = Vector2(28, 49)
    hint_label.add_theme_font_size_override("font_size", 14)
    hint_label.add_theme_color_override("font_color", Color("#a9b8ca"))
    top.add_child(hint_label)

    var x = 650
    for data in [["小球", "ball"], ["木板", "board"], ["斜坡", "slope"]]:
        var b = Button.new()
        b.text = data[0]
        b.position = Vector2(x, 18)
        b.size = Vector2(90, 50)
        b.add_theme_font_size_override("font_size", 16)
        _style_button(b, false)
        b.pressed.connect(_add_piece.bind(data[1]))
        top.add_child(b)
        palette_buttons.append(b)
        x += 100

    run_button = Button.new()
    run_button.text = "▶ 开始"
    run_button.position = Vector2(960, 18)
    run_button.size = Vector2(120, 50)
    run_button.add_theme_font_size_override("font_size", 17)
    _style_button(run_button, true)
    run_button.pressed.connect(toggle_run)
    top.add_child(run_button)

    var reset_button = Button.new()
    reset_button.text = "↻ 重置"
    reset_button.position = Vector2(1090, 18)
    reset_button.size = Vector2(90, 50)
    reset_button.add_theme_font_size_override("font_size", 17)
    _style_button(reset_button, false)
    reset_button.pressed.connect(reset_level)
    top.add_child(reset_button)

    var status_panel = Panel.new()
    status_panel.position = Vector2(30, 610)
    status_panel.size = Vector2(440, 58)
    status_panel.add_theme_stylebox_override("panel", _make_style(Color("#0b1018e8"), Color("#304158"), 12, 1))
    layer.add_child(status_panel)

    status_label = Label.new()
    status_label.text = "准备就绪 · 拖动机关，然后点击开始"
    status_label.position = Vector2(16, 9)
    status_label.add_theme_font_size_override("font_size", 16)
    status_label.add_theme_color_override("font_color", Color("#eef4fb"))
    status_panel.add_child(status_label)

func _create_boundary() -> void:
    var floor = StaticBody2D.new()
    floor.position = Vector2(640, 700)
    var floor_shape = CollisionShape2D.new()
    var floor_rect = RectangleShape2D.new()
    floor_rect.size = Vector2(1280, 24)
    floor_shape.shape = floor_rect
    floor.add_child(floor_shape)
    add_child(floor)

    var left = StaticBody2D.new()
    left.position = Vector2(8, 397)
    var left_shape = CollisionShape2D.new()
    var left_rect = RectangleShape2D.new()
    left_rect.size = Vector2(16, 600)
    left_shape.shape = left_rect
    left.add_child(left_shape)
    add_child(left)

    var right = StaticBody2D.new()
    right.position = Vector2(1272, 397)
    var right_shape = CollisionShape2D.new()
    var right_rect = RectangleShape2D.new()
    right_rect.size = Vector2(16, 600)
    right_shape.shape = right_rect
    right.add_child(right_shape)
    add_child(right)

func _build_level() -> void:
    _create_boundary()

    target = Area2D.new()
    target.name = "Target"
    target.position = TARGET_POS
    var target_shape = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = 48
    target_shape.shape = circle
    target.add_child(target_shape)
    add_child(target)
    target.body_entered.connect(_on_target_body_entered)

    # Level 1 is a solvable staircase: each slope descends to the right,
    # the next slope catches the ball, and the final board carries it through the goal.
    _create_piece("slope", Vector2(350, 300), 0.30)
    _create_piece("slope", Vector2(600, 400), 0.30)
    _create_piece("slope", Vector2(850, 500), 0.30)
    _create_piece("board", Vector2(1060, 590), 0.12)
    ball = _create_piece("ball", Vector2(310, 155), 0.0)
    status_label.text = "第 1 关 · 让小球沿斜坡滚入右下角目标"

func _create_piece(kind: String, pos: Vector2, rot: float = 0.0) -> MachinePiece:
    var body: PhysicsBody2D
    if kind == "ball":
        body = RigidBody2D.new()
        body.set("freeze", true)
        body.set("mass", 1.0)
        body.set("gravity_scale", 1.0)
        body.set("linear_damp", 0.05)
        body.set("angular_damp", 0.05)
    else:
        body = StaticBody2D.new()

    body.set_script(load("res://piece.gd"))
    var piece := body as MachinePiece
    piece.setup(kind, self, pos, rot)

    if kind == "slope":
        var poly = CollisionPolygon2D.new()
        poly.polygon = PackedVector2Array([Vector2(-125, 22), Vector2(125, -22), Vector2(125, 22), Vector2(-125, 22)])
        piece.add_child(poly)
    else:
        var shape = CollisionShape2D.new()
        if kind == "ball":
            var c = CircleShape2D.new()
            c.radius = 24
            shape.shape = c
        else:
            var rect = RectangleShape2D.new()
            rect.size = Vector2(250, 30)
            shape.shape = rect
        piece.add_child(shape)

    add_child(piece)
    pieces.append(piece)
    return piece

func _add_piece(kind: String) -> void:
    if running:
        return
    var pos = Vector2(500, 250)
    if kind == "ball":
        pos = Vector2(250, 170)
    elif kind == "board":
        pos = Vector2(500, 300)
    elif kind == "slope":
        pos = Vector2(500, 400)
    var p = _create_piece(kind, pos)
    select_piece(p)
    status_label.text = "已添加 %s · 拖动它到合适位置" % kind

func select_piece(piece: MachinePiece) -> void:
    selected_piece = piece
    for p in pieces:
        p.queue_redraw()

func clamp_piece(piece: MachinePiece) -> void:
    var p = piece.global_position
    p.x = clamp(p.x, 35.0, 1245.0)
    p.y = clamp(p.y, 120.0, 675.0)
    piece.global_position = p

func toggle_run() -> void:
    if won:
        return
    running = not running
    if running:
        run_button.text = "⏸ 暂停"
        status_label.text = "运行中 · 观察小球能否完成路线…"
        if ball:
            ball.set("freeze", false)
            ball.set("sleeping", false)
    else:
        run_button.text = "▶ 继续"
        status_label.text = "已暂停 · 可以继续或重置"
        if ball:
            ball.set("freeze", true)
    for b in palette_buttons:
        b.disabled = running
    queue_redraw()

func reset_level() -> void:
    running = false
    won = false
    run_button.text = "▶ 开始"
    for p in pieces:
        p.reset_piece()
    if ball:
        ball.set("freeze", true)
    status_label.text = "已重置 · 第 1 关：沿斜坡把小球送入目标"
    for b in palette_buttons:
        b.disabled = false
    queue_redraw()

func _on_target_body_entered(body: Node2D) -> void:
    if body == ball and running and not won:
        won = true
        running = false
        ball.set("freeze", true)
        run_button.text = "✓ 完成"
        status_label.text = "🎉 成功！小球进入目标区。点击重置再试一次。"
        queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("#0e1218"))
    draw_rect(BOARD_BOUNDS, Color("#151b24"), true)
    draw_rect(BOARD_BOUNDS, Color("#2c3a4e"), false, 2)

    for x in range(40, 1260, 40):
        draw_line(Vector2(x, 105), Vector2(x, 690), Color(1, 1, 1, 0.035), 1)
    for y in range(120, 700, 40):
        draw_line(Vector2(20, y), Vector2(1260, y), Color(1, 1, 1, 0.035), 1)

    draw_rect(Rect2(20, 688, 1240, 2), Color("#34445a"), true)

    var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.004) * 0.05 if not won else 1.08
    draw_circle(TARGET_POS, 50.0 * pulse, Color(0.25, 0.85, 0.45, 0.13))
    draw_arc(TARGET_POS, 48.0 * pulse, 0, TAU, 48, Color("#62df8c"), 4.0)
    draw_circle(TARGET_POS, 20.0, Color(0.25, 0.85, 0.45, 0.22))
    draw_string(ThemeDB.fallback_font, TARGET_POS + Vector2(-36, 76), "TARGET", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#72d8ff"))
