extends Node2D

enum GameState { EDITING, RUNNING, PAUSED, SUCCESS }

var game_state := GameState.EDITING
var selected_piece: MachinePiece = null
var pieces: Array = []
var ball: MachinePiece = null
var target: Area2D = null
var status_label: Label
var hint_label: Label
var run_button: Button
var level_option: OptionButton
var palette_buttons: Array[Button] = []
var level_index := 0

const BOARD_BOUNDS := Rect2(20, 125, 1240, 565)
const TARGET_POS := Vector2(1130, 620)

func _ready() -> void:
    get_viewport().physics_object_picking_sort = true
    _build_ui()
    _create_boundary()
    _load_level(0)
    queue_redraw()

func is_simulation_running() -> bool:
    return game_state == GameState.RUNNING

func is_editing() -> bool:
    return game_state == GameState.EDITING

func _make_style(bg: Color, border: Color, radius: int = 10, border_width: int = 1) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.set_border_width_all(border_width)
    s.set_corner_radius_all(radius)
    s.content_margin_left = 10
    s.content_margin_right = 10
    s.content_margin_top = 7
    s.content_margin_bottom = 7
    return s

func _style_button(button: Button, accent := false) -> void:
    var normal = _make_style(Color("#26364d") if not accent else Color("#1688ff"), Color("#4d6685") if not accent else Color("#80caff"), 9, 1)
    var hover = _make_style(Color("#344b68") if not accent else Color("#32a0ff"), Color("#8da9c9") if not accent else Color("#c7ebff"), 9, 1)
    var pressed = _make_style(Color("#1b293c") if not accent else Color("#0f6fcb"), Color("#91b4dc") if not accent else Color("#e2f5ff"), 9, 2)
    var disabled = _make_style(Color("#171e28"), Color("#2a3544"), 9, 1)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("focus", hover)
    button.add_theme_stylebox_override("disabled", disabled)
    button.add_theme_color_override("font_color", Color("#f5f8fc"))
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    button.add_theme_color_override("font_pressed_color", Color.WHITE)
    button.add_theme_color_override("font_disabled_color", Color("#718096"))

func _style_option(option: OptionButton) -> void:
    var normal = _make_style(Color("#26364d"), Color("#4d6685"), 9, 1)
    var hover = _make_style(Color("#344b68"), Color("#8da9c9"), 9, 1)
    option.add_theme_stylebox_override("normal", normal)
    option.add_theme_stylebox_override("hover", hover)
    option.add_theme_stylebox_override("pressed", normal)
    option.add_theme_color_override("font_color", Color("#f5f8fc"))
    option.add_theme_color_override("font_hover_color", Color.WHITE)

func _build_ui() -> void:
    var layer = CanvasLayer.new()
    layer.name = "UI"
    add_child(layer)
    var top = Panel.new()
    top.size = Vector2(1280, 118)
    top.add_theme_stylebox_override("panel", _make_style(Color("#0b1018"), Color("#263348"), 0, 0))
    layer.add_child(top)
    var title = Label.new()
    title.text = "TINY MACHINE  ·  P1"
    title.position = Vector2(24, 7)
    title.add_theme_font_size_override("font_size", 24)
    title.add_theme_color_override("font_color", Color("#f2f6fb"))
    top.add_child(title)
    hint_label = Label.new()
    hint_label.text = "编辑：拖动机关  ·  运行：物理接管  ·  目标区进入后立即结束本次模拟并判定通关"
    hint_label.position = Vector2(24, 39)
    hint_label.add_theme_font_size_override("font_size", 14)
    hint_label.add_theme_color_override("font_color", Color("#a9b8ca"))
    top.add_child(hint_label)
    level_option = OptionButton.new()
    level_option.position = Vector2(20, 68)
    level_option.size = Vector2(150, 42)
    level_option.add_item("01 基础斜坡")
    level_option.add_item("02 P1 机关演示")
    level_option.selected = 0
    level_option.add_theme_font_size_override("font_size", 14)
    _style_option(level_option)
    level_option.item_selected.connect(_on_level_selected)
    top.add_child(level_option)
    var palette = [["小球", "ball"], ["木板", "board"], ["斜坡", "slope"], ["弹簧", "spring"], ["绳子", "rope"], ["剪刀", "scissors"], ["齿轮", "gear"], ["开关", "switch"], ["气球", "balloon"]]
    var x := 180.0
    for data in palette:
        var b = Button.new()
        b.text = data[0]
        b.position = Vector2(x, 68)
        b.size = Vector2(84, 42)
        b.add_theme_font_size_override("font_size", 14)
        _style_button(b, false)
        b.pressed.connect(_add_piece.bind(data[1]))
        top.add_child(b)
        palette_buttons.append(b)
        x += 90.0
    run_button = Button.new()
    run_button.text = "▶ 开始"
    run_button.position = Vector2(1005, 68)
    run_button.size = Vector2(120, 42)
    run_button.add_theme_font_size_override("font_size", 16)
    _style_button(run_button, true)
    run_button.pressed.connect(toggle_run)
    top.add_child(run_button)
    var reset_button = Button.new()
    reset_button.text = "↻ 重置"
    reset_button.position = Vector2(1135, 68)
    reset_button.size = Vector2(110, 42)
    reset_button.add_theme_font_size_override("font_size", 16)
    _style_button(reset_button, false)
    reset_button.pressed.connect(reset_level)
    top.add_child(reset_button)
    var status_panel = Panel.new()
    status_panel.position = Vector2(30, 615)
    status_panel.size = Vector2(520, 58)
    status_panel.add_theme_stylebox_override("panel", _make_style(Color("#0b1018e8"), Color("#304158"), 12, 1))
    layer.add_child(status_panel)
    status_label = Label.new()
    status_label.text = "准备就绪"
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
    left.position = Vector2(8, 407)
    var left_shape = CollisionShape2D.new()
    var left_rect = RectangleShape2D.new()
    left_rect.size = Vector2(16, 600)
    left_shape.shape = left_rect
    left.add_child(left_shape)
    add_child(left)
    var right = StaticBody2D.new()
    right.position = Vector2(1272, 407)
    var right_shape = CollisionShape2D.new()
    var right_rect = RectangleShape2D.new()
    right_rect.size = Vector2(16, 600)
    right_shape.shape = right_rect
    right.add_child(right_shape)
    add_child(right)

func _clear_level() -> void:
    for p in pieces:
        if is_instance_valid(p): p.queue_free()
    pieces.clear()
    if is_instance_valid(target): target.queue_free()
    target = null
    ball = null
    selected_piece = null

func _load_level(index: int) -> void:
    game_state = GameState.EDITING
    level_index = index
    _clear_level()
    _create_target()
    if level_index == 0: _build_level_01()
    else: _build_level_02()
    run_button.text = "▶ 开始"
    for b in palette_buttons: b.disabled = false
    queue_redraw()

func _create_target() -> void:
    target = Area2D.new()
    target.name = "Target"
    target.position = TARGET_POS
    target.collision_layer = 4
    target.collision_mask = 1
    var target_shape = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = 48
    target_shape.shape = circle
    target.add_child(target_shape)
    add_child(target)
    target.body_entered.connect(_on_target_body_entered)

func _build_level_01() -> void:
    _create_piece("slope", Vector2(350, 315), 0.30)
    _create_piece("slope", Vector2(600, 415), 0.30)
    _create_piece("slope", Vector2(850, 515), 0.30)
    _create_piece("board", Vector2(1060, 600), 0.12)
    ball = _create_piece("ball", Vector2(310, 170), 0.0)
    status_label.text = "第 1 关 · 基础物理：让小球沿斜坡进入目标"

func _build_level_02() -> void:
    _create_piece("slope", Vector2(380, 260), 0.30)
    _create_piece("slope", Vector2(600, 370), 0.30)
    _create_piece("slope", Vector2(820, 480), 0.30)
    _create_piece("switch", Vector2(720, 485), 0.0)
    _create_piece("gear", Vector2(885, 505), 0.0)
    _create_piece("spring", Vector2(1000, 560), 0.10)
    _create_piece("board", Vector2(1080, 610), 0.05)
    _create_piece("rope", Vector2(340, 520), 0.0)
    _create_piece("scissors", Vector2(500, 520), 0.0)
    _create_piece("balloon", Vector2(1030, 300), 0.0)
    ball = _create_piece("ball", Vector2(300, 155), 0.0)
    status_label.text = "第 2 关 · P1：开关 → 齿轮/弹簧 → 目标；绳子与剪刀可直接测试"

func _create_piece(kind: String, pos: Vector2, rot: float = 0.0) -> MachinePiece:
    var body: Node2D
    if kind == "ball" or kind == "balloon":
        body = RigidBody2D.new()
        body.set("freeze", true)
        body.set("mass", 1.0 if kind == "ball" else 0.8)
        body.set("gravity_scale", 1.0 if kind == "ball" else -0.22)
        body.set("linear_damp", 0.08)
        body.set("angular_damp", 0.08)
        body.set("continuous_cd", RigidBody2D.CCD_MODE_CAST_SHAPE)
    elif kind == "gear": body = AnimatableBody2D.new()
    else: body = StaticBody2D.new()
    var collider := body as CollisionObject2D
    if collider == null:
        push_error("MachinePiece factory requires CollisionObject2D")
        return null
    body.set_script(load("res://piece.gd"))
    var piece := body as MachinePiece
    piece.setup(kind, self, pos, rot)
    var solid := kind == "ball" or kind == "balloon" or kind == "board" or kind == "slope" or kind == "gear"
    if solid:
        collider.collision_layer = 1
        collider.collision_mask = 1
    else:
        collider.collision_layer = 2
        collider.collision_mask = 0
    var shape = CollisionShape2D.new()
    if kind == "slope":
        var poly = CollisionPolygon2D.new()
        poly.polygon = PackedVector2Array([Vector2(-125, 22), Vector2(125, -22), Vector2(125, 22), Vector2(-125, 22)])
        piece.add_child(poly)
    elif kind == "ball" or kind == "balloon":
        var c = CircleShape2D.new()
        c.radius = 24.0 if kind == "ball" else 28.0
        shape.shape = c
        piece.add_child(shape)
    elif kind == "gear":
        var gc = CircleShape2D.new()
        gc.radius = 42.0
        shape.shape = gc
        piece.add_child(shape)
    elif kind == "board":
        var rect = RectangleShape2D.new()
        rect.size = Vector2(250, 30)
        shape.shape = rect
        piece.add_child(shape)
    elif kind == "spring":
        var spring_rect = RectangleShape2D.new()
        spring_rect.size = Vector2(110, 26)
        shape.shape = spring_rect
        piece.add_child(shape)
    elif kind == "rope":
        var rope_rect = RectangleShape2D.new()
        rope_rect.size = Vector2(180, 20)
        shape.shape = rope_rect
        piece.add_child(shape)
    elif kind == "scissors":
        var scissor_rect = RectangleShape2D.new()
        scissor_rect.size = Vector2(96, 34)
        shape.shape = scissor_rect
        piece.add_child(shape)
    elif kind == "switch":
        var switch_rect = RectangleShape2D.new()
        switch_rect.size = Vector2(110, 28)
        shape.shape = switch_rect
        piece.add_child(shape)
    add_child(piece)
    pieces.append(piece)
    return piece

func _add_piece(kind: String) -> void:
    if game_state != GameState.EDITING: return
    var pos = Vector2(600, 330)
    if kind == "ball": pos = Vector2(260, 170)
    elif kind == "board": pos = Vector2(560, 300)
    elif kind == "slope": pos = Vector2(560, 400)
    elif kind == "spring": pos = Vector2(650, 450)
    elif kind == "rope": pos = Vector2(600, 300)
    elif kind == "scissors": pos = Vector2(600, 380)
    elif kind == "gear": pos = Vector2(700, 450)
    elif kind == "switch": pos = Vector2(700, 350)
    elif kind == "balloon": pos = Vector2(700, 280)
    var p = _create_piece(kind, pos)
    if p == null: return
    if kind == "ball": ball = p
    select_piece(p)
    status_label.text = "已添加 %s · 拖动它到合适位置" % kind

func select_piece(piece: MachinePiece) -> void:
    selected_piece = piece
    for p in pieces: p.queue_redraw()

func clamp_piece(piece: MachinePiece) -> void:
    var p = piece.global_position
    p.x = clamp(p.x, 45.0, 1235.0)
    p.y = clamp(p.y, 145.0, 670.0)
    piece.global_position = p

func _set_simulation_frozen(frozen: bool) -> void:
    for p in pieces:
        if not is_instance_valid(p): continue
        p.simulation_enabled = not frozen
        if p is RigidBody2D:
            p.freeze = frozen
            if not frozen: p.sleeping = false

func toggle_run() -> void:
    if game_state == GameState.SUCCESS: return
    if game_state == GameState.EDITING:
        game_state = GameState.RUNNING
        _set_simulation_frozen(false)
        run_button.text = "⏸ 暂停"
        status_label.text = "运行中 · 目标区进入后立即结束本次模拟"
    elif game_state == GameState.RUNNING:
        game_state = GameState.PAUSED
        _set_simulation_frozen(true)
        run_button.text = "▶ 继续"
        status_label.text = "已暂停 · 可以继续或重置"
    elif game_state == GameState.PAUSED:
        game_state = GameState.RUNNING
        _set_simulation_frozen(false)
        run_button.text = "⏸ 暂停"
        status_label.text = "继续运行中…"
    level_option.disabled = game_state != GameState.EDITING
    for b in palette_buttons: b.disabled = game_state != GameState.EDITING
    queue_redraw()

func reset_level() -> void:
    game_state = GameState.EDITING
    for p in pieces:
        if is_instance_valid(p): p.reset_piece()
    run_button.text = "▶ 开始"
    level_option.disabled = false
    for b in palette_buttons: b.disabled = false
    status_label.text = "已重置 · " + ("第 1 关：沿斜坡把小球送入目标" if level_index == 0 else "第 2 关：测试 P1 机关")
    queue_redraw()

func _on_level_selected(index: int) -> void:
    if game_state == GameState.EDITING: _load_level(index)

func _finish_success() -> void:
    if game_state == GameState.SUCCESS: return
    game_state = GameState.SUCCESS
    _set_simulation_frozen(true)
    for p in pieces:
        if p is RigidBody2D:
            p.linear_velocity = Vector2.ZERO
            p.angular_velocity = 0.0
        p.simulation_enabled = false
    run_button.text = "✓ 完成"
    level_option.disabled = true
    for b in palette_buttons: b.disabled = true
    status_label.text = "🎉 通关！小球进入目标区，本次模拟已结束。点击重置再试。"
    queue_redraw()

func _on_target_body_entered(body: Node2D) -> void:
    if body == ball and game_state == GameState.RUNNING: _finish_success()

func _physics_process(_delta: float) -> void:
    if game_state != GameState.RUNNING or ball == null or not is_instance_valid(ball): return
    for p in pieces:
        if not is_instance_valid(p): continue
        var distance := ball.global_position.distance_to(p.global_position)
        if p.piece_type == "switch" and not p.triggered and distance < 62.0:
            p.triggered = true
            p.active = true
            for linked in pieces:
                if linked.piece_type == "gear" or linked.piece_type == "spring": linked.active = true
            status_label.text = "开关已触发 · 机关开始工作"
            p.queue_redraw()
        elif p.piece_type == "spring" and p.active and not p.triggered and distance < 72.0:
            p.triggered = true
            ball.apply_central_impulse(Vector2.RIGHT.rotated(p.rotation) * 620.0)
            status_label.text = "弹簧触发 · 小球被弹射"
            p.queue_redraw()
        elif p.piece_type == "gear" and p.active and not p.triggered and distance < 76.0:
            p.triggered = true
            ball.apply_central_impulse(Vector2.RIGHT.rotated(p.rotation + PI * 0.5) * 260.0)
            status_label.text = "齿轮啮合 · 旋转传递到小球"
            p.queue_redraw()
        elif p.piece_type == "scissors" and not p.triggered and distance < 80.0:
            for rope in pieces:
                if rope.piece_type == "rope" and not rope.cut and p.global_position.distance_to(rope.global_position) < 90.0:
                    rope.cut_rope()
                    p.triggered = true
                    status_label.text = "✂ 绳子已剪断"
                    p.queue_redraw()
                    break

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("#0e1218"))
    draw_rect(BOARD_BOUNDS, Color("#151b24"), true)
    draw_rect(BOARD_BOUNDS, Color("#2c3a4e"), false, 2)
    for x in range(40, 1260, 40): draw_line(Vector2(x, 125), Vector2(x, 690), Color(1, 1, 1, 0.035), 1)
    for y in range(140, 700, 40): draw_line(Vector2(20, y), Vector2(1260, y), Color(1, 1, 1, 0.035), 1)
    draw_rect(Rect2(20, 688, 1240, 2), Color("#34445a"), true)
    var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.004) * 0.05 if game_state != GameState.SUCCESS else 1.08
    var target_color = Color("#62df8c") if game_state != GameState.SUCCESS else Color("#7ff7a6")
    draw_circle(TARGET_POS, 50.0 * pulse, Color(0.25, 0.85, 0.45, 0.13))
    draw_arc(TARGET_POS, 48.0 * pulse, 0, TAU, 48, target_color, 4.0)
    draw_circle(TARGET_POS, 20.0, Color(0.25, 0.85, 0.45, 0.22))
    draw_string(ThemeDB.fallback_font, TARGET_POS + Vector2(-36, 76), "TARGET", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#72d8ff"))
