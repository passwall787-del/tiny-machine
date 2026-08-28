extends Node2D

const BOARD := Rect2(20, 158, 1240, 525)
const GRID := 20.0
const MAX_HISTORY := 50
const LEVEL_FILE := "res://levels.json"
const SAVE_FILE := "user://tiny_machine_custom_level.json"

enum GameState { EDITING, RUNNING, PAUSED, SUCCESS, FAIL }

var state := GameState.EDITING
var levels: Array[LevelData] = []
var current_level_index := 0
var current_level: LevelData
var runtime: LevelRuntime
var selected: Array[MachineComponent] = []
var history_undo: Array = []
var history_redo: Array = []
var drag_before_layout: Array = []
var drag_start_positions: Dictionary = {}
var drag_primary_start := Vector2.ZERO
var multi_select := false
var snap_enabled := true
var elapsed := 0.0
var run_timeout := 18.0
var last_ball_position := Vector2.ZERO
var success_scheduled := false
var goal_pulse := 0.0

var audio: AudioManager
var title_label: Label
var status_label: Label
var tutorial_label: Label
var level_option: OptionButton
var run_button: Button
var multi_button: Button
var snap_button: Button
var music_button: Button
var editor_buttons: Array[Button] = []
var result_panel: Panel
var result_label: Label
var result_retry: Button
var result_next: Button

func _ready() -> void:
    _load_levels()
    audio = AudioManager.new()
    add_child(audio)
    runtime = LevelRuntime.new(self, self)
    _build_ui()
    _create_boundaries()
    _load_level(0)

func is_editing() -> bool:
    return state == GameState.EDITING

func is_piece_selected(piece: MachineComponent) -> bool:
    return selected.has(piece)

func _load_levels() -> void:
    var text := FileAccess.get_file_as_string(LEVEL_FILE)
    var parsed = JSON.parse_string(text)
    if not parsed is Dictionary:
        push_error("Invalid levels.json")
        return
    for raw in parsed.get("levels", []):
        if raw is Dictionary: levels.append(LevelData.from_dict(raw))

func _create_boundaries() -> void:
    for spec in [[Vector2(640,696),Vector2(1280,28)],[Vector2(8,420),Vector2(16,560)],[Vector2(1272,420),Vector2(16,560)]]:
        var body := StaticBody2D.new()
        body.position = spec[0]
        var shape := CollisionShape2D.new()
        var rect := RectangleShape2D.new()
        rect.size = spec[1]
        shape.shape = rect
        body.add_child(shape)
        add_child(body)

func _style_button(button: Button, accent := false) -> void:
    button.add_theme_stylebox_override("normal", _style(Color("#26364d") if not accent else Color("#177fe6"), Color("#536d8f") if not accent else Color("#8bd1ff")))
    button.add_theme_stylebox_override("hover", _style(Color("#344b68") if not accent else Color("#2e9cff"), Color("#a4bddb") if not accent else Color("#d5f1ff")))
    button.add_theme_stylebox_override("pressed", _style(Color("#18263a") if not accent else Color("#0f68b6"), Color("#b6d0ef") if not accent else Color.WHITE, 9, 2))
    button.add_theme_stylebox_override("disabled", _style(Color("#171e28"), Color("#2a3544")))
    button.add_theme_color_override("font_color", Color("#f5f8fc"))
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    button.add_theme_color_override("font_pressed_color", Color.WHITE)
    button.add_theme_color_override("font_disabled_color", Color("#778598"))

func _style(bg: Color, border: Color, radius := 9, width := 1) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.set_border_width_all(width)
    s.set_corner_radius_all(radius)
    return s

func _build_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var top := Panel.new()
    top.size = Vector2(1280,150)
    top.add_theme_stylebox_override("panel", _style(Color("#090e15"), Color("#243247"), 0, 0))
    layer.add_child(top)

    title_label = Label.new()
    title_label.position = Vector2(20,8)
    title_label.add_theme_font_size_override("font_size",23)
    title_label.add_theme_color_override("font_color",Color("#f5f8fc"))
    top.add_child(title_label)

    status_label = Label.new()
    status_label.position = Vector2(300,12)
    status_label.size = Vector2(940,30)
    status_label.add_theme_font_size_override("font_size",14)
    status_label.add_theme_color_override("font_color",Color("#b9c7d8"))
    top.add_child(status_label)

    level_option = OptionButton.new()
    level_option.position = Vector2(20,48)
    level_option.size = Vector2(245,44)
    level_option.add_theme_font_size_override("font_size",15)
    level_option.add_theme_stylebox_override("normal",_style(Color("#26364d"),Color("#5a7495")))
    level_option.add_theme_color_override("font_color",Color("#f5f8fc"))
    level_option.item_selected.connect(_on_level_selected)
    top.add_child(level_option)

    var palette := [["球","ball"],["木板","board"],["斜坡","slope"],["弹簧","spring"],["绳","rope"],["剪刀","scissors"],["齿轮","gear"],["开关","switch"],["气球","balloon"],["磁铁","magnet"],["炸弹","bomb"]]
    var x := 275.0
    for item in palette:
        var b := Button.new()
        b.text = item[0]
        b.position = Vector2(x,48)
        b.size = Vector2(68,44)
        b.add_theme_font_size_override("font_size",13)
        _style_button(b)
        b.pressed.connect(_add_component.bind(item[1]))
        top.add_child(b)
        editor_buttons.append(b)
        x += 70.0

    run_button = Button.new()
    run_button.text = "▶ 运行"
    run_button.position = Vector2(1055,48)
    run_button.size = Vector2(105,44)
    run_button.add_theme_font_size_override("font_size",15)
    _style_button(run_button,true)
    run_button.pressed.connect(toggle_run)
    top.add_child(run_button)

    var reset := Button.new()
    reset.text = "↻ 重置"
    reset.position = Vector2(1168,48)
    reset.size = Vector2(90,44)
    _style_button(reset)
    reset.pressed.connect(retry_level)
    top.add_child(reset)

    var tools := [["多选","multi"],["旋转","rotate"],["删除","delete"],["撤销","undo"],["重做","redo"],["吸附","snap"],["保存","save"],["加载","load"],["验证","validate"],["音乐","music"]]
    x = 20.0
    for item in tools:
        var b := Button.new()
        b.text = item[0]
        b.position = Vector2(x,101)
        b.size = Vector2(100,38)
        b.add_theme_font_size_override("font_size",13)
        _style_button(b)
        b.pressed.connect(_tool_pressed.bind(item[1]))
        top.add_child(b)
        editor_buttons.append(b)
        if item[1] == "multi": multi_button = b
        if item[1] == "snap": snap_button = b
        if item[1] == "music": music_button = b
        x += 106.0

    tutorial_label = Label.new()
    tutorial_label.position = Vector2(20,698)
    tutorial_label.size = Vector2(1220,20)
    tutorial_label.add_theme_font_size_override("font_size",13)
    tutorial_label.add_theme_color_override("font_color",Color("#b9c7d8"))
    layer.add_child(tutorial_label)

    result_panel = Panel.new()
    result_panel.position = Vector2(370,280)
    result_panel.size = Vector2(540,170)
    result_panel.add_theme_stylebox_override("panel",_style(Color("#0c1721f2"),Color("#65df93"),18,2))
    result_panel.visible = false
    layer.add_child(result_panel)
    result_label = Label.new()
    result_label.position = Vector2(20,20)
    result_label.size = Vector2(500,75)
    result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    result_label.add_theme_font_size_override("font_size",25)
    result_label.add_theme_color_override("font_color",Color("#e8fff0"))
    result_panel.add_child(result_label)
    result_retry = Button.new()
    result_retry.text = "再试一次"
    result_retry.position = Vector2(125,112)
    result_retry.size = Vector2(120,42)
    _style_button(result_retry)
    result_retry.pressed.connect(retry_level)
    result_panel.add_child(result_retry)
    result_next = Button.new()
    result_next.text = "下一关"
    result_next.position = Vector2(295,112)
    result_next.size = Vector2(120,42)
    _style_button(result_next,true)
    result_next.pressed.connect(next_level)
    result_panel.add_child(result_next)

func _refresh_levels() -> void:
    level_option.clear()
    for level in levels:
        level_option.add_item("%02d · %s · ★%d" % [level.id,level.title,level.difficulty])
    level_option.selected = current_level_index

func _load_level(index: int) -> void:
    if levels.is_empty(): return
    current_level_index = clampi(index,0,levels.size()-1)
    current_level = levels[current_level_index].duplicate_level()
    runtime.load_level(current_level)
    selected.clear()
    history_undo.clear()
    history_redo.clear()
    state = GameState.EDITING
    elapsed = 0.0
    success_scheduled = false
    last_ball_position = runtime.ball.global_position if runtime.ball else Vector2.ZERO
    result_panel.visible = false
    result_retry.text = "再试一次"
    run_button.text = "▶ 运行"
    title_label.text = "TINY MACHINE · P2/P3 · %02d" % current_level.id
    status_label.text = "第 %02d 关：%s" % [current_level.id,current_level.title]
    _refresh_levels()
    _update_tutorial()
    _update_controls()
    queue_redraw()

func _update_tutorial() -> void:
    var tips := {1:"教程 1：拖动组件，让小球沿斜坡进入绿色目标。",2:"教程 2：旋转与网格吸附。",3:"教程 3：多选一次移动多个组件。",4:"教程 4：撤销/重做快速试错。",5:"教程 5：进入目标区立即结束模拟。"}
    if current_level and current_level.tutorial:
        tutorial_label.text = tips.get(current_level.id,"教程：观察路径，再运行。")
    elif current_level:
        tutorial_label.text = "难度 ★%d · 目标：进入绿色区域 · 掉出场地或 18 秒超时失败" % current_level.difficulty

func _update_controls() -> void:
    var editing := is_editing()
    level_option.disabled = not editing
    for b in editor_buttons: b.disabled = not editing
    run_button.disabled = state in [GameState.SUCCESS,GameState.FAIL]
    if multi_button: multi_button.text = "多选 ✓" if multi_select else "多选"
    if snap_button: snap_button.text = "吸附 ✓" if snap_enabled else "吸附"
    if music_button: music_button.text = "音乐 ✓" if audio.music_enabled else "音乐"

func _tool_pressed(tool: String) -> void:
    if not is_editing(): return
    audio.click()
    match tool:
        "multi":
            multi_select = not multi_select
            if not multi_select and selected.size() > 1: selected = [selected[0]]
        "rotate": _rotate_selected()
        "delete": _delete_selected()
        "undo": _undo()
        "redo": _redo()
        "snap":
            snap_enabled = not snap_enabled
            if snap_enabled: _snap_selected()
        "save": _save_custom_level()
        "load": _load_custom_level()
        "validate": _validate_current(true)
        "music": audio.set_enabled(not audio.music_enabled)
    _update_controls()
    queue_redraw()

func on_piece_pressed(piece: MachineComponent) -> void:
    if not is_editing(): return
    if multi_select:
        if selected.has(piece):
            if selected.size() > 1: selected.erase(piece)
        else: selected.append(piece)
    else:
        selected = [piece]
    drag_before_layout = runtime.capture_layout()
    drag_start_positions.clear()
    for item in selected: drag_start_positions[item.get_instance_id()] = item.global_position
    drag_primary_start = piece.global_position
    _update_selection_visuals()

func on_piece_released(_piece: MachineComponent) -> void:
    if not is_editing(): return
    var after := runtime.capture_layout()
    if not drag_before_layout.is_empty() and JSON.stringify(drag_before_layout) != JSON.stringify(after):
        history_undo.append(drag_before_layout)
        if history_undo.size() > MAX_HISTORY: history_undo.pop_front()
        history_redo.clear()
    drag_before_layout.clear()
    drag_start_positions.clear()
    _sync_working_level()
    _validate_current(false)

func drag_piece_to(_piece: MachineComponent,target: Vector2) -> void:
    if not is_editing() or selected.is_empty(): return
    var delta := target - drag_primary_start
    for item in selected:
        if not drag_start_positions.has(item.get_instance_id()): continue
        var pos: Vector2 = drag_start_positions[item.get_instance_id()] + delta
        if snap_enabled: pos = _snap(pos)
        pos.x = clampf(pos.x,45.0,1235.0)
        pos.y = clampf(pos.y,175.0,670.0)
        item.global_position = pos
    queue_redraw()

func _sync_working_level() -> void:
    if current_level == null or runtime == null: return
    current_level.pieces.clear()
    for item in runtime.capture_layout():
        if item is Dictionary: current_level.pieces.append(item.duplicate(true))

func _snap(pos: Vector2) -> Vector2:
    return Vector2(round(pos.x/GRID)*GRID,round(pos.y/GRID)*GRID)

func _snap_selected() -> void:
    if selected.is_empty(): return
    _push_undo_snapshot()
    for piece in selected: piece.global_position = _snap(piece.global_position)
    _sync_working_level()

func _rotate_selected() -> void:
    if selected.is_empty(): return
    _push_undo_snapshot()
    for piece in selected: piece.rotation += deg_to_rad(15.0)
    _sync_working_level()
    status_label.text = "已旋转 %d 个组件" % selected.size()

func _delete_selected() -> void:
    if selected.is_empty(): return
    _push_undo_snapshot()
    for piece in selected:
        if is_instance_valid(piece):
            runtime.components.erase(piece)
            piece.queue_free()
    selected.clear()
    _sync_working_level()
    status_label.text = "已删除组件"

func _push_undo_snapshot() -> void:
    history_undo.append(runtime.capture_layout())
    if history_undo.size() > MAX_HISTORY: history_undo.pop_front()
    history_redo.clear()

func _undo() -> void:
    if history_undo.is_empty(): return
    history_redo.append(runtime.capture_layout())
    var previous: Array = history_undo.pop_back()
    runtime.apply_layout(previous)
    selected.clear()
    _sync_working_level()
    status_label.text = "已撤销"

func _redo() -> void:
    if history_redo.is_empty(): return
    history_undo.append(runtime.capture_layout())
    var next: Array = history_redo.pop_back()
    runtime.apply_layout(next)
    selected.clear()
    _sync_working_level()
    status_label.text = "已重做"

func _add_component(kind: String) -> void:
    if not is_editing(): return
    _push_undo_snapshot()
    var data := {"type":kind,"x":620.0,"y":350.0,"r":0.0}
    if kind == "ball":
        data["x"] = 300.0
        data["y"] = 180.0
    var piece := ComponentFactory.create_component(kind,data,self,self)
    if piece:
        runtime.components.append(piece)
        selected = [piece]
        _sync_working_level()
        status_label.text = "已添加 %s" % kind
    queue_redraw()

func _validate_current(show_message := true) -> Dictionary:
    if current_level == null: return {"ok":false,"errors":["没有当前关卡"],"warnings":[]}
    var result: Dictionary = LevelValidator.validate(runtime.capture_level())
    if show_message:
        if bool(result.get("ok",false)): status_label.text = "✓ 关卡验证通过"
        else: status_label.text = "✗ " + "; ".join(result.get("errors",[]))
    return result

func _save_custom_level() -> void:
    var result := _validate_current(false)
    if not bool(result.get("ok",false)):
        status_label.text = "无法保存：请先修复验证错误"
        return
    var data := runtime.capture_level()
    data.id = 9000
    data.title = "我的机械实验"
    var file := FileAccess.open(SAVE_FILE,FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data.to_dict(),"  "))
        file.close()
        status_label.text = "已保存到本机"

func _load_custom_level() -> void:
    if not FileAccess.file_exists(SAVE_FILE):
        status_label.text = "还没有本机保存的关卡"
        return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_FILE))
    if not parsed is Dictionary:
        status_label.text = "本机存档损坏"
        return
    var data := LevelData.from_dict(parsed)
    var result := LevelValidator.validate(data)
    if not bool(result.get("ok",false)):
        status_label.text = "本机存档无效"
        return
    current_level = data
    runtime.load_level(data)
    selected.clear()
    state = GameState.EDITING
    success_scheduled = false
    result_panel.visible = false
    status_label.text = "已加载本机自制关卡"
    title_label.text = "TINY MACHINE · 自制关卡"
    _update_controls()

func toggle_run() -> void:
    if state in [GameState.SUCCESS,GameState.FAIL]: return
    if state == GameState.EDITING:
        var result := _validate_current(false)
        if not bool(result.get("ok",false)):
            status_label.text = "不能运行：" + "; ".join(result.get("errors",[]))
            return
        state = GameState.RUNNING
        elapsed = 0.0
        success_scheduled = false
        last_ball_position = runtime.ball.global_position if runtime.ball else Vector2.ZERO
        result_panel.visible = false
        runtime.set_simulation(true)
        run_button.text = "⏸ 暂停"
        status_label.text = "运行中…"
    elif state == GameState.RUNNING:
        state = GameState.PAUSED
        runtime.set_simulation(false)
        run_button.text = "▶ 继续"
        status_label.text = "已暂停"
    elif state == GameState.PAUSED:
        state = GameState.RUNNING
        runtime.set_simulation(true)
        run_button.text = "⏸ 暂停"
        status_label.text = "继续运行中…"
    _update_controls()

func retry_level() -> void:
    if current_level == null: return
    runtime.load_level(current_level)
    selected.clear()
    state = GameState.EDITING
    elapsed = 0.0
    success_scheduled = false
    last_ball_position = runtime.ball.global_position if runtime.ball else Vector2.ZERO
    result_panel.visible = false
    result_retry.text = "再试一次"
    run_button.text = "▶ 运行"
    _update_controls()
    status_label.text = "已重置"
    queue_redraw()

func next_level() -> void:
    if current_level_index + 1 < levels.size(): _load_level(current_level_index + 1)
    else: status_label.text = "🎉 已完成全部 32 个官方关卡"

func _on_level_selected(index: int) -> void:
    if is_editing(): _load_level(index)

func _on_goal_body_entered(body: Node2D) -> void:
    if state != GameState.RUNNING or runtime == null or body != runtime.ball: return
    if success_scheduled: return
    success_scheduled = true
    state = GameState.SUCCESS
    call_deferred("_finalize_success")

func _segment_hits_goal(a: Vector2,b: Vector2,center: Vector2,radius: float) -> bool:
    var ab := b-a
    var length_sq := ab.length_squared()
    if length_sq <= 0.0001: return a.distance_to(center) <= radius
    var t := clampf((center-a).dot(ab)/length_sq,0.0,1.0)
    return (a+ab*t).distance_to(center) <= radius

func _finalize_success() -> void:
    if runtime == null: return
    runtime.set_simulation(false)
    for piece in runtime.components:
        var node: Node = piece
        if node is RigidBody2D:
            var rb: RigidBody2D = node
            rb.linear_velocity = Vector2.ZERO
            rb.angular_velocity = 0.0
    result_panel.visible = true
    result_next.visible = current_level_index + 1 < levels.size()
    result_label.text = "✓ 关卡完成\n%s" % current_level.title
    status_label.text = "通关：目标区进入后，本次模拟已终止。"
    run_button.text = "✓ 完成"
    _update_controls()
    var tween := create_tween()
    result_panel.modulate.a = 0.0
    result_panel.scale = Vector2(0.92,0.92)
    tween.set_parallel(true)
    tween.tween_property(result_panel,"modulate:a",1.0,0.2)
    tween.tween_property(result_panel,"scale",Vector2.ONE,0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    audio.success()

func _finish_fail(reason: String) -> void:
    if state != GameState.RUNNING: return
    state = GameState.FAIL
    runtime.set_simulation(false)
    result_panel.visible = true
    result_next.visible = false
    result_label.text = "✕ 还差一点\n%s" % reason
    status_label.text = "失败：%s" % reason
    result_retry.text = "重新尝试"
    _update_controls()
    audio.failure()

func _update_selection_visuals() -> void:
    for piece in runtime.components:
        if is_instance_valid(piece): piece.queue_redraw()

func _process(delta: float) -> void:
    goal_pulse += delta
    if state == GameState.RUNNING and runtime != null and runtime.ball != null:
        var current_pos := runtime.ball.global_position
        if runtime.goal != null and _segment_hits_goal(last_ball_position,current_pos,runtime.goal.position,runtime.level.goal_radius+24.0):
            _on_goal_body_entered(runtime.ball)
        elif current_pos.y > 710.0:
            _finish_fail("小球掉出场地")
        else:
            elapsed += delta
            if elapsed > run_timeout: _finish_fail("超过 18 秒")
            else: _process_mechanics()
        last_ball_position = current_pos
    queue_redraw()

func _process_mechanics() -> void:
    var ball_pos := runtime.ball.global_position
    for piece in runtime.components:
        if not is_instance_valid(piece): continue
        var distance := ball_pos.distance_to(piece.global_position)
        if piece.piece_type == "switch" and not piece.triggered and distance < 62.0:
            piece.triggered = true
            piece.active = true
            for other in runtime.components:
                if other.piece_type in ["gear","spring"]: other.active = true
            audio.click()
        elif piece.piece_type == "spring" and piece.active and not piece.triggered and distance < 72.0:
            piece.triggered = true
            runtime.ball.apply_impulse(Vector2.RIGHT.rotated(piece.rotation)*620.0)
        elif piece.piece_type == "gear" and piece.active and not piece.triggered and distance < 76.0:
            piece.triggered = true
            runtime.ball.apply_impulse(Vector2.RIGHT.rotated(piece.rotation+PI*0.5)*260.0)
        elif piece.piece_type == "magnet" and not piece.spent and distance < 180.0:
            piece.active = true
            runtime.ball.apply_impulse((piece.global_position-ball_pos).normalized()*clampf(180.0-distance,20.0,150.0)*0.35)
        elif piece.piece_type == "bomb" and not piece.spent and distance < 58.0:
            piece.spent = true
            runtime.ball.apply_impulse((ball_pos-piece.global_position).normalized()*520.0+Vector2(0,-180.0))
        elif piece.piece_type == "scissors" and not piece.triggered and distance < 80.0:
            for rope in runtime.components:
                if rope.piece_type == "rope" and not rope.cut and piece.global_position.distance_to(rope.global_position) < 100.0:
                    rope.cut_rope()
                    piece.triggered = true
                    audio.click()
                    break

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("#0e1218"))
    draw_rect(BOARD,Color("#151c25"),true)
    draw_rect(BOARD,Color("#2c3d52"),false,2)
    for x in range(40,1260,40): draw_line(Vector2(x,158),Vector2(x,683),Color(1,1,1,0.035),1)
    for y in range(180,700,40): draw_line(Vector2(20,y),Vector2(1260,y),Color(1,1,1,0.035),1)
    if runtime != null and runtime.goal != null:
        var p := 1.0 + sin(goal_pulse*4.0)*0.06
        draw_circle(runtime.goal.position,52.0*p,Color(0.25,0.85,0.45,0.12))
        draw_arc(runtime.goal.position,48.0*p,0,TAU,48,Color("#7df0a3"),4.0)
        draw_circle(runtime.goal.position,18.0,Color(0.25,0.85,0.45,0.22))
        draw_string(ThemeDB.fallback_font,runtime.goal.position+Vector2(-36,75),"TARGET",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("#72d8ff"))
    if snap_enabled and state == GameState.EDITING:
        for x in range(40,1260,int(GRID)): draw_line(Vector2(x,158),Vector2(x,683),Color(0.3,0.6,0.9,0.025),1)
        for y in range(180,700,int(GRID)): draw_line(Vector2(20,y),Vector2(1260,y),Color(0.3,0.6,0.9,0.025),1)
