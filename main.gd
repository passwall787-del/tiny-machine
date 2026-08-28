extends Node2D

const BOARD := Rect2(20, 98, 1240, 445)
const GRID := 20.0
const MAX_HISTORY := 50
const LEVEL_FILE := "res://levels.json"
const SAVE_FILE := "user://tiny_machine_custom_level.json"
const PARTS := [
    {"kind":"board","title":"木板","color":Color("#d99a5b")},
    {"kind":"slope","title":"斜坡","color":Color("#e0a15f")},
    {"kind":"spring","title":"弹簧","color":Color("#4ea8ff")},
    {"kind":"rope","title":"绳子","color":Color("#e4a741")},
    {"kind":"scissors","title":"剪刀","color":Color("#e77e72")},
    {"kind":"gear","title":"齿轮","color":Color("#6daeff")},
    {"kind":"switch","title":"开关","color":Color("#4bd58a")},
    {"kind":"balloon","title":"气球","color":Color("#ff748e")},
    {"kind":"magnet","title":"磁铁","color":Color("#ef6876")},
    {"kind":"bomb","title":"炸弹","color":Color("#e45b5b")}
]

var state := GameState.EDITING
enum GameState { EDITING, RUNNING, PAUSED, SUCCESS, FAIL }

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
var spawn_serial := 0

var audio: AudioManager
var title_label: Label
var status_label: Label
var objective_label: Label
var tutorial_label: Label
var inventory_label: Label
var level_option: OptionButton
var run_button: Button
var reset_button: Button
var multi_button: Button
var snap_button: Button
var music_button: Button
var editor_buttons: Array[Button] = []
var part_buttons: Dictionary = {}
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
    levels.clear()
    var text := FileAccess.get_file_as_string(LEVEL_FILE)
    var parsed = JSON.parse_string(text)
    if not parsed is Dictionary:
        push_error("Invalid levels.json")
        return
    for raw in parsed.get("levels", []):
        if raw is Dictionary: levels.append(LevelData.from_dict(raw))

func _create_boundaries() -> void:
    for spec in [[Vector2(640,548),Vector2(1280,24)],[Vector2(8,320),Vector2(16,470)],[Vector2(1272,320),Vector2(16,470)]]:
        var body := StaticBody2D.new()
        body.position = spec[0]
        var shape := CollisionShape2D.new()
        var rect := RectangleShape2D.new()
        rect.size = spec[1]
        shape.shape = rect
        body.add_child(shape)
        add_child(body)

func _style(bg: Color, border: Color, radius := 10, width := 1, shadow := true) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.set_border_width_all(width)
    s.set_corner_radius_all(radius)
    if shadow:
        s.shadow_color = Color(0,0,0,0.28)
        s.shadow_size = 5
        s.shadow_offset = Vector2(0,3)
    return s

func _style_button(button: Button, accent := false) -> void:
    button.add_theme_stylebox_override("normal", _style(Color("#233448") if not accent else Color("#168cff"), Color("#5d7898") if not accent else Color("#9edcff"), 10, 1))
    button.add_theme_stylebox_override("hover", _style(Color("#304862") if not accent else Color("#35a4ff"), Color("#a7c8e8") if not accent else Color("#d8f2ff"), 10, 1))
    button.add_theme_stylebox_override("pressed", _style(Color("#172535") if not accent else Color("#0d6fc4"), Color("#c4dcf4") if not accent else Color.WHITE, 10, 2))
    button.add_theme_stylebox_override("disabled", _style(Color("#171f29"), Color("#303d4c"), 10, 1, false))
    button.add_theme_color_override("font_color", Color("#f5f8fc"))
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    button.add_theme_color_override("font_pressed_color", Color.WHITE)
    button.add_theme_color_override("font_disabled_color", Color("#718094"))

func _style_part_button(button: PartButton) -> void:
    button.add_theme_stylebox_override("normal", _style(Color("#1d2b3a"), Color("#40566d"), 12, 1))
    button.add_theme_stylebox_override("hover", _style(Color("#263b51"), Color("#72c7ff"), 12, 2))
    button.add_theme_stylebox_override("pressed", _style(Color("#142131"), Color("#9bdcff"), 12, 2))
    button.add_theme_stylebox_override("disabled", _style(Color("#131a22"), Color("#2a3643"), 12, 1, false))

func _build_ui() -> void:
    var layer := CanvasLayer.new()
    layer.name = "UI"
    add_child(layer)

    var top := Panel.new()
    top.position = Vector2(0,0)
    top.size = Vector2(1280,92)
    top.add_theme_stylebox_override("panel", _style(Color("#09121c"), Color("#1f3449"), 0, 0, false))
    layer.add_child(top)

    title_label = Label.new()
    title_label.position = Vector2(20,7)
    title_label.add_theme_font_size_override("font_size",22)
    title_label.add_theme_color_override("font_color",Color("#f5f8fc"))
    title_label.add_theme_color_override("font_shadow_color",Color(0,0,0,0.5))
    title_label.add_theme_constant_override("shadow_offset_x",1)
    title_label.add_theme_constant_override("shadow_offset_y",2)
    top.add_child(title_label)

    status_label = Label.new()
    status_label.position = Vector2(315,7)
    status_label.size = Vector2(700,25)
    status_label.add_theme_font_size_override("font_size",14)
    status_label.add_theme_color_override("font_color",Color("#d4e2ef"))
    top.add_child(status_label)

    objective_label = Label.new()
    objective_label.position = Vector2(315,29)
    objective_label.size = Vector2(690,22)
    objective_label.add_theme_font_size_override("font_size",13)
    objective_label.add_theme_color_override("font_color",Color("#7f9ab4"))
    top.add_child(objective_label)

    level_option = OptionButton.new()
    level_option.position = Vector2(20,43)
    level_option.size = Vector2(275,40)
    level_option.add_theme_font_size_override("font_size",14)
    level_option.add_theme_stylebox_override("normal",_style(Color("#1c2b3a"),Color("#4b6883"),9,1))
    level_option.add_theme_stylebox_override("hover",_style(Color("#263b50"),Color("#76c7ff"),9,1))
    level_option.add_theme_color_override("font_color",Color("#f5f8fc"))
    level_option.item_selected.connect(_on_level_selected)
    top.add_child(level_option)

    var tools := [["多选","multi"],["旋转","rotate"],["删除","delete"],["撤销","undo"],["重做","redo"],["吸附","snap"],["音乐","music"]]
    var x := 315.0
    for item in tools:
        var b := Button.new()
        b.text = item[0]
        b.position = Vector2(x,55)
        b.size = Vector2(72,30)
        b.add_theme_font_size_override("font_size",12)
        _style_button(b)
        b.pressed.connect(_tool_pressed.bind(item[1]))
        top.add_child(b)
        editor_buttons.append(b)
        if item[1] == "multi": multi_button = b
        if item[1] == "snap": snap_button = b
        if item[1] == "music": music_button = b
        x += 78.0

    reset_button = Button.new()
    reset_button.text = "↻ 清空"
    reset_button.position = Vector2(1018,18)
    reset_button.size = Vector2(92,48)
    reset_button.add_theme_font_size_override("font_size",14)
    _style_button(reset_button)
    reset_button.pressed.connect(retry_level)
    top.add_child(reset_button)

    run_button = Button.new()
    run_button.text = "▶ 发射小球"
    run_button.position = Vector2(1118,18)
    run_button.size = Vector2(142,48)
    run_button.add_theme_font_size_override("font_size",15)
    _style_button(run_button,true)
    run_button.pressed.connect(toggle_run)
    top.add_child(run_button)

    var parts_panel := Panel.new()
    parts_panel.position = Vector2(0,548)
    parts_panel.size = Vector2(1280,172)
    parts_panel.add_theme_stylebox_override("panel",_style(Color("#0b141e"),Color("#24384b"),0,0,false))
    layer.add_child(parts_panel)

    var parts_title := Label.new()
    parts_title.position = Vector2(18,7)
    parts_title.add_theme_font_size_override("font_size",16)
    parts_title.add_theme_color_override("font_color",Color("#edf5fc"))
    parts_title.text = "零件仓库"
    parts_panel.add_child(parts_title)

    inventory_label = Label.new()
    inventory_label.position = Vector2(118,9)
    inventory_label.add_theme_font_size_override("font_size",12)
    inventory_label.add_theme_color_override("font_color",Color("#819bb2"))
    parts_panel.add_child(inventory_label)

    var hint := Label.new()
    hint.position = Vector2(700,9)
    hint.size = Vector2(560,22)
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    hint.text = "点击添加 · 拖动调整 · 旋转15° · 最后点击“发射小球”"
    hint.add_theme_font_size_override("font_size",12)
    hint.add_theme_color_override("font_color",Color("#7590a8"))
    parts_panel.add_child(hint)

    for i in range(PARTS.size()):
        var info: Dictionary = PARTS[i]
        var button := PartButton.new()
        button.position = Vector2(18 + i * 96, 39)
        button.size = Vector2(88,122)
        button.setup(str(info["kind"]),str(info["title"]),0,info["color"])
        _style_part_button(button)
        button.pressed.connect(_add_component.bind(str(info["kind"])))
        parts_panel.add_child(button)
        part_buttons[str(info["kind"])] = button

    var result_info := Panel.new()
    result_info.position = Vector2(1000,39)
    result_info.size = Vector2(260,122)
    result_info.add_theme_stylebox_override("panel",_style(Color("#142333"),Color("#2d465e"),12,1))
    parts_panel.add_child(result_info)
    var info_title := Label.new()
    info_title.position = Vector2(14,10)
    info_title.text = "施工流程"
    info_title.add_theme_font_size_override("font_size",14)
    info_title.add_theme_color_override("font_color",Color("#e9f2fa"))
    result_info.add_child(info_title)
    var info_text := Label.new()
    info_text.position = Vector2(14,36)
    info_text.size = Vector2(232,75)
    info_text.text = "① 从仓库取零件\n② 拖到施工区并调整角度\n③ 观察绿色目标\n④ 发射小球，验证连锁反应"
    info_text.add_theme_font_size_override("font_size",12)
    info_text.add_theme_color_override("font_color",Color("#9eb3c7"))
    result_info.add_child(info_text)

    tutorial_label = Label.new()
    tutorial_label.position = Vector2(36,514)
    tutorial_label.size = Vector2(1160,25)
    tutorial_label.add_theme_font_size_override("font_size",13)
    tutorial_label.add_theme_color_override("font_color",Color("#506b82"))
    layer.add_child(tutorial_label)

    result_panel = Panel.new()
    result_panel.position = Vector2(355,235)
    result_panel.size = Vector2(570,190)
    result_panel.add_theme_stylebox_override("panel",_style(Color("#0b1723f5"),Color("#66df94"),18,2))
    result_panel.visible = false
    layer.add_child(result_panel)

    result_label = Label.new()
    result_label.position = Vector2(20,20)
    result_label.size = Vector2(530,90)
    result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    result_label.add_theme_font_size_override("font_size",24)
    result_label.add_theme_color_override("font_color",Color("#edfff3"))
    result_panel.add_child(result_label)

    result_retry = Button.new()
    result_retry.text = "重新施工"
    result_retry.position = Vector2(120,130)
    result_retry.size = Vector2(135,42)
    _style_button(result_retry)
    result_retry.pressed.connect(retry_level)
    result_panel.add_child(result_retry)

    result_next = Button.new()
    result_next.text = "下一关"
    result_next.position = Vector2(315,130)
    result_next.size = Vector2(135,42)
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
    current_level.pieces.clear()
    runtime.load_level(current_level)
    selected.clear()
    history_undo.clear()
    history_redo.clear()
    state = GameState.EDITING
    elapsed = 0.0
    success_scheduled = false
    last_ball_position = runtime.ball.global_position if runtime.ball else Vector2.ZERO
    result_panel.visible = false
    run_button.text = "▶ 发射小球"
    reset_button.text = "↻ 清空"
    title_label.text = "TINY MACHINE · 施工台"
    status_label.text = "第 %02d 关 · %s" % [current_level.id,current_level.title]
    objective_label.text = "目标：让小球从起点进入绿色目标区 · 施工区为空，零件全部由你放置"
    _refresh_levels()
    _update_tutorial()
    _update_controls()
    _refresh_inventory()
    queue_redraw()

func _update_tutorial() -> void:
    var tips := {
        1:"教程 1：先放两块斜坡和一块木板，理解“摆放 → 发射 → 观察”。",
        2:"教程 2：练习旋转斜坡，让小球改变运动方向。",
        3:"教程 3：用多选一次移动一组零件。",
        4:"教程 4：大胆试错，撤销/重做会保留你的施工思路。",
        5:"教程 5：小球进入目标区会立即结束本次模拟。"
    }
    if current_level and current_level.tutorial:
        tutorial_label.text = tips.get(current_level.id,"教程：先搭机器，再发射小球。")
    elif current_level:
        tutorial_label.text = "难度 ★%d · 零件有限 · 你不必用完所有库存 · 施工完成后再发射" % current_level.difficulty

func _placed_count(kind: String) -> int:
    var count := 0
    if runtime == null: return count
    for piece in runtime.components:
        if is_instance_valid(piece) and piece.piece_type == kind: count += 1
    return count

func _inventory_remaining(kind: String) -> int:
    if current_level == null: return 0
    return maxi(0, int(current_level.inventory.get(kind,0)) - _placed_count(kind))

func _refresh_inventory() -> void:
    var total := 0
    for info in PARTS:
        var kind := str(info["kind"])
        var remaining := _inventory_remaining(kind)
        total += remaining
        if part_buttons.has(kind):
            var button: PartButton = part_buttons[kind]
            button.set_count(remaining)
            button.disabled = not is_editing() or remaining <= 0
    inventory_label.text = "可用零件 %d" % total

func _update_controls() -> void:
    var editing := is_editing()
    level_option.disabled = not editing
    for b in editor_buttons: b.disabled = not editing
    run_button.disabled = editing and runtime != null and runtime.components.is_empty()
    run_button.disabled = run_button.disabled or state in [GameState.SUCCESS,GameState.FAIL]
    reset_button.disabled = false
    if multi_button: multi_button.text = "多选 ✓" if multi_select else "多选"
    if snap_button: snap_button.text = "吸附 ✓" if snap_enabled else "吸附"
    if music_button: music_button.text = "音乐 ✓" if audio.music_enabled else "音乐"
    _refresh_inventory()

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
        "music": audio.set_enabled(not audio.music_enabled)
    _update_controls()
    queue_redraw()

func on_piece_pressed(piece: MachineComponent) -> void:
    if not is_editing() or not piece.editable: return
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

func drag_piece_to(_piece: MachineComponent,target: Vector2) -> void:
    if not is_editing() or selected.is_empty(): return
    var delta := target - drag_primary_start
    for item in selected:
        if not drag_start_positions.has(item.get_instance_id()): continue
        var pos: Vector2 = drag_start_positions[item.get_instance_id()] + delta
        if snap_enabled: pos = _snap(pos)
        pos.x = clampf(pos.x,45.0,1235.0)
        pos.y = clampf(pos.y,112.0,522.0)
        item.global_position = pos
    queue_redraw()

func _sync_working_level() -> void:
    if current_level == null or runtime == null: return
    current_level.pieces.clear()
    for item in runtime.capture_layout():
        if item is Dictionary: current_level.pieces.append(item.duplicate(true))
    _refresh_inventory()

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
    status_label.text = "已旋转 %d 个零件" % selected.size()

func _delete_selected() -> void:
    if selected.is_empty(): return
    _push_undo_snapshot()
    for piece in selected:
        if is_instance_valid(piece):
            runtime.components.erase(piece)
            piece.queue_free()
    selected.clear()
    _sync_working_level()
    status_label.text = "零件已放回仓库"

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
    status_label.text = "已撤销上一步施工"

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
    var remaining := _inventory_remaining(kind)
    if remaining <= 0:
        status_label.text = "%s 已用完" % _part_title(kind)
        return
    _push_undo_snapshot()
    var index := runtime.components.size()
    var pos := Vector2(460.0 + float(index % 4) * 100.0, 280.0 + float(index / 4) * 70.0)
    if snap_enabled: pos = _snap(pos)
    var data := {"type":kind,"x":pos.x,"y":pos.y,"r":0.0}
    var piece := ComponentFactory.create_component(kind,data,self,self)
    if piece:
        runtime.components.append(piece)
        selected = [piece]
        spawn_serial += 1
        _sync_working_level()
        status_label.text = "已添加 %s · 拖动它调整位置" % _part_title(kind)
        audio.click()
    queue_redraw()

func _part_title(kind: String) -> String:
    for info in PARTS:
        if str(info["kind"]) == kind: return str(info["title"])
    return kind

func _validate_current(show_message := true) -> Dictionary:
    if current_level == null: return {"ok":false,"errors":["没有当前关卡"],"warnings":[]}
    var result: Dictionary = LevelValidator.validate(runtime.capture_level())
    if show_message:
        if bool(result.get("ok",false)):
            status_label.text = "✓ 施工结构合法 · 已放置 %d 个零件" % runtime.components.size()
        else:
            status_label.text = "✗ " + "; ".join(result.get("errors",[]))
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
        status_label.text = "已保存本机施工方案"

func _load_custom_level() -> void:
    if not FileAccess.file_exists(SAVE_FILE):
        status_label.text = "还没有本机保存的方案"
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
    run_button.text = "▶ 发射小球"
    title_label.text = "TINY MACHINE · 自制施工台"
    status_label.text = "已加载本机施工方案"
    objective_label.text = "目标：进入绿色区域 · 你可以继续调整零件后再发射"
    _update_controls()
    _sync_working_level()

func toggle_run() -> void:
    if state in [GameState.SUCCESS,GameState.FAIL]: return
    if state == GameState.EDITING:
        if runtime == null or runtime.components.is_empty():
            status_label.text = "请先从零件仓库添加至少一个零件"
            return
        var result := _validate_current(false)
        if not bool(result.get("ok",false)):
            status_label.text = "不能发射：" + "; ".join(result.get("errors",[]))
            return
        state = GameState.RUNNING
        elapsed = 0.0
        success_scheduled = false
        last_ball_position = runtime.ball.global_position if runtime.ball else Vector2.ZERO
        result_panel.visible = false
        runtime.set_simulation(true)
        run_button.text = "⏸ 暂停"
        reset_button.text = "■ 停止"
        status_label.text = "机器启动 · 小球已发射"
        audio.click()
    elif state == GameState.RUNNING:
        state = GameState.PAUSED
        runtime.set_simulation(false)
        run_button.text = "▶ 继续"
        reset_button.text = "↻ 清空"
        status_label.text = "已暂停 · 继续观察或清空重做"
    elif state == GameState.PAUSED:
        state = GameState.RUNNING
        runtime.set_simulation(true)
        run_button.text = "⏸ 暂停"
        reset_button.text = "■ 停止"
        status_label.text = "机器继续运行…"
    _update_controls()

func retry_level() -> void:
    if current_level == null: return
    var clean := current_level.duplicate_level()
    clean.pieces.clear()
    current_level = clean
    runtime.load_level(current_level)
    selected.clear()
    state = GameState.EDITING
    elapsed = 0.0
    success_scheduled = false
    last_ball_position = runtime.ball.global_position if runtime.ball else Vector2.ZERO
    result_panel.visible = false
    run_button.text = "▶ 发射小球"
    reset_button.text = "↻ 清空"
    status_label.text = "施工区已清空 · 从零开始搭建"
    _update_controls()
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
    status_label.text = "通关 · 目标区进入后，本次模拟已立即终止"
    run_button.text = "✓ 已完成"
    reset_button.text = "↻ 再施工"
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
    status_label.text = "失败 · %s · 可以重新施工" % reason
    result_retry.text = "重新施工"
    run_button.text = "↻ 重做"
    _update_controls()
    audio.failure()

func _update_selection_visuals() -> void:
    for piece in runtime.components:
        if is_instance_valid(piece): piece.queue_redraw()

func _prepare_test_solution() -> void:
    if current_level == null: return
    var test_level := current_level.with_solution_layout()
    runtime.load_level(test_level)
    selected.clear()
    state = GameState.EDITING
    elapsed = 0.0
    success_scheduled = false
    last_ball_position = runtime.ball.global_position if runtime.ball else Vector2.ZERO
    result_panel.visible = false
    _sync_working_level()

func _process(delta: float) -> void:
    goal_pulse += delta
    if state == GameState.RUNNING and runtime != null and runtime.ball != null:
        var current_pos := runtime.ball.global_position
        if runtime.goal != null and _segment_hits_goal(last_ball_position,current_pos,runtime.goal.position,runtime.level.goal_radius+24.0):
            _on_goal_body_entered(runtime.ball)
        elif current_pos.y > 570.0:
            _finish_fail("小球掉出施工区")
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
            audio.click()
        elif piece.piece_type == "gear" and piece.active and not piece.triggered and distance < 76.0:
            piece.triggered = true
            runtime.ball.apply_impulse(Vector2.RIGHT.rotated(piece.rotation+PI*0.5)*260.0)
            audio.click()
        elif piece.piece_type == "magnet" and not piece.spent and distance < 180.0:
            piece.active = true
            runtime.ball.apply_impulse((piece.global_position-ball_pos).normalized()*clampf(180.0-distance,20.0,150.0)*0.35)
        elif piece.piece_type == "bomb" and not piece.spent and distance < 58.0:
            piece.spent = true
            runtime.ball.apply_impulse((ball_pos-piece.global_position).normalized()*520.0+Vector2(0,-180.0))
            audio.failure()
        elif piece.piece_type == "scissors" and not piece.triggered and distance < 80.0:
            for rope in runtime.components:
                if rope.piece_type == "rope" and not rope.cut and piece.global_position.distance_to(rope.global_position) < 100.0:
                    rope.cut_rope()
                    piece.triggered = true
                    audio.click()
                    break

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("#0a1119"))

    draw_rect(BOARD,Color("#d8e4ec"),true)
    draw_rect(BOARD,Color("#7891a6"),false,3)
    draw_rect(Rect2(26,104,1228,28),Color("#c5d5e0"),true)
    draw_line(Vector2(26,132),Vector2(1254,132),Color("#91a8b9"),2)
    draw_string(ThemeDB.fallback_font,Vector2(42,123),"CONSTRUCTION ZONE",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("#587188"))

    for x in range(40,1260,40):
        draw_line(Vector2(x,132),Vector2(x,542),Color(0.2,0.35,0.45,0.08),1)
    for y in range(150,543,40):
        draw_line(Vector2(20,y),Vector2(1260,y),Color(0.2,0.35,0.45,0.08),1)

    for x in range(50,1250,100):
        draw_circle(Vector2(x,107),3,Color("#6f8798"))
        draw_circle(Vector2(x,538),3,Color("#6f8798"))

    if runtime != null and runtime.ball != null and state == GameState.EDITING:
        var start := runtime.ball.global_position
        draw_circle(start + Vector2(0,25),38,Color(0,0,0,0.10))
        draw_arc(start,34,0,TAU,40,Color("#5c7a92"),2)
        draw_string(ThemeDB.fallback_font,start+Vector2(-31,50),"START",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("#5c768d"))
        draw_line(start+Vector2(40,0),start+Vector2(78,0),Color("#7893a8"),2)
        draw_line(start+Vector2(78,0),start+Vector2(68,-7),Color("#7893a8"),2)
        draw_line(start+Vector2(78,0),start+Vector2(68,7),Color("#7893a8"),2)

    if runtime != null and runtime.goal != null:
        var p := 1.0 + sin(goal_pulse*4.0)*0.06
        var glow := Color("#49d58a") if state != GameState.SUCCESS else Color("#70f5a4")
        draw_circle(runtime.goal.position,58.0*p,Color(0.20,0.85,0.50,0.10))
        draw_arc(runtime.goal.position,49.0*p,0,TAU,56,glow,4)
        draw_arc(runtime.goal.position,38.0,0,TAU,48,Color(0.25,0.75,0.55,0.35),2)
        draw_circle(runtime.goal.position,18.0,Color(0.25,0.85,0.45,0.18))
        draw_string(ThemeDB.fallback_font,runtime.goal.position+Vector2(-36,72),"TARGET",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#4f7a6b"))

    if snap_enabled and state == GameState.EDITING:
        draw_string(ThemeDB.fallback_font,Vector2(1090,525),"GRID 20",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("#6d8799"))
