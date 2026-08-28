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

func _build_ui() -> void:
    var layer = CanvasLayer.new()
    layer.name = "UI"
    add_child(layer)

    var top = Panel.new()
    top.position = Vector2(0, 0)
    top.size = Vector2(1280, 88)
    top.modulate = Color(0.08, 0.10, 0.13, 0.97)
    layer.add_child(top)

    var title = Label.new()
    title.text = "TINY MACHINE  ·  P0"
    title.position = Vector2(28, 14)
    title.add_theme_font_size_override("font_size", 24)
    top.add_child(title)

    hint_label = Label.new()
    hint_label.text = "编辑模式：拖动机关摆放位置  ·  目标：让小球进入绿色目标区"
    hint_label.position = Vector2(28, 50)
    hint_label.add_theme_font_size_override("font_size", 14)
    hint_label.modulate = Color("#a9b5c6")
    top.add_child(hint_label)

    var x = 650
    for data in [["小球", "ball"], ["木板", "board"], ["斜坡", "slope"]]:
        var b = Button.new()
        b.text = data[0]
        b.position = Vector2(x, 18)
        b.size = Vector2(90, 50)
        b.add_theme_font_size_override("font_size", 16)
        b.pressed.connect(_add_piece.bind(data[1]))
        top.add_child(b)
        palette_buttons.append(b)
        x += 100

    run_button = Button.new()
    run_button.text = "▶ 开始"
    run_button.position = Vector2(960, 18)
    run_button.size = Vector2(120, 50)
    run_button.add_theme_font_size_override("font_size", 17)
    run_button.pressed.connect(toggle_run)
    top.add_child(run_button)

    var reset_button = Button.new()
    reset_button.text = "↻ 重置"
    reset_button.position = Vector2(1090, 18)
    reset_button.size = Vector2(90, 50)
    reset_button.add_theme_font_size_override("font_size", 17)
    reset_button.pressed.connect(reset_level)
    top.add_child(reset_button)

    var status_panel = Panel.new()
    status_panel.position = Vector2(30, 610)
    status_panel.size = Vector2(360, 58)
    status_panel.modulate = Color(0.08, 0.10, 0.13, 0.92)
    layer.add_child(status_panel)

    status_label = Label.new()
    status_label.text = "准备就绪 · 拖动机关，然后点击开始"
    status_label.position = Vector2(16, 9)
    status_label.add_theme_font_size_override("font_size", 16)
    status_panel.add_child(status_label)

func _build_level() -> void:
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

    _create_piece("slope", Vector2(360, 420), -0.12)
    _create_piece("board", Vector2(680, 510), 0.0)
    ball = _create_piece("ball", Vector2(180, 180), 0.0)
    _create_piece("board", Vector2(850, 620), 0.0)
    status_label.text = "准备就绪 · 把小球引导到右下角绿色目标"

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

    var shape = CollisionShape2D.new()
    if kind == "ball":
        var c = CircleShape2D.new()
        c.radius = 24
        shape.shape = c
    else:
        var rect = RectangleShape2D.new()
        rect.size = Vector2(250, 30)
        shape.shape = rect
        if kind == "slope":
            piece.rotation = rot - 0.18
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
        status_label.text = "运行中 · 观察连锁反应…"
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
    status_label.text = "已重置 · 拖动机关，然后点击开始"
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
    draw_rect(BOARD_BOUNDS, Color("#273140"), false, 2)

    for x in range(40, 1260, 40):
        draw_line(Vector2(x, 105), Vector2(x, 690), Color(1, 1, 1, 0.025), 1)
    for y in range(120, 700, 40):
        draw_line(Vector2(20, y), Vector2(1260, y), Color(1, 1, 1, 0.025), 1)

    var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.004) * 0.05 if not won else 1.08
    draw_circle(TARGET_POS, 50.0 * pulse, Color(0.25, 0.85, 0.45, 0.13))
    draw_arc(TARGET_POS, 48.0 * pulse, 0, TAU, 48, Color("#62df8c"), 4.0)
    draw_circle(TARGET_POS, 20.0, Color(0.25, 0.85, 0.45, 0.22))
    draw_string(ThemeDB.fallback_font, TARGET_POS + Vector2(-36, 76), "TARGET", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#72d8ff"))
