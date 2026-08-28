extends RefCounted
class_name LevelRuntime

var owner_main: Node
var editor: Node
var components: Array[MachineComponent] = []
var ball: MachineComponent
var goal: Area2D
var level: LevelData

func _init(main_node: Node, editor_node: Node) -> void:
    owner_main = main_node
    editor = editor_node

func load_level(data: LevelData) -> void:
    clear()
    level = data.duplicate_level()
    goal = Area2D.new()
    goal.name = "Goal"
    goal.position = level.goal_position
    goal.collision_layer = 4
    goal.collision_mask = 1
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = level.goal_radius
    shape.shape = circle
    goal.add_child(shape)
    owner_main.add_child(goal)
    goal.body_entered.connect(Callable(owner_main, "_on_goal_body_entered"))

    for item in level.pieces:
        var piece := ComponentFactory.create_component(str(item.get("type", "")), item, owner_main, editor)
        if piece == null: continue
        components.append(piece)
        if piece.piece_type == "ball" and ball == null: ball = piece
    reset_runtime()

func clear() -> void:
    for piece in components:
        if is_instance_valid(piece): piece.queue_free()
    components.clear()
    ball = null
    if is_instance_valid(goal): goal.queue_free()
    goal = null

func reset_runtime() -> void:
    for piece in components:
        if is_instance_valid(piece): piece.reset_runtime()

func set_simulation(enabled: bool) -> void:
    for piece in components:
        if is_instance_valid(piece): piece.set_simulation(enabled)

func capture_layout() -> Array:
    var result: Array = []
    for piece in components:
        if not is_instance_valid(piece): continue
        result.append({"type":piece.piece_type,"x":piece.global_position.x,"y":piece.global_position.y,"r":piece.rotation})
    return result

func capture_level() -> LevelData:
    var out := level.duplicate_level()
    out.pieces.clear()
    for item in capture_layout():
        if item is Dictionary: out.pieces.append(item.duplicate(true))
    return out

func apply_layout(layout: Array) -> void:
    var out := level.duplicate_level()
    out.pieces.clear()
    for item in layout:
        if item is Dictionary: out.pieces.append(item.duplicate(true))
    load_level(out)
