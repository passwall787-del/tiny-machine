extends RefCounted
class_name LevelData

var id: int = 0
var title: String = ""
var difficulty: int = 1
var tutorial: bool = false
var pattern: String = "basic"
var slope_count: int = 2
var start_position := Vector2(150, 150)
var goal_position := Vector2(1080, 500)
var goal_radius: float = 48.0
var pieces: Array[Dictionary] = []
var solution_pieces: Array[Dictionary] = []
var inventory: Dictionary = {}

static func from_dict(raw: Dictionary) -> LevelData:
    var level := LevelData.new()
    level.id = int(raw.get("id", 0))
    level.title = str(raw.get("title", "未命名关卡"))
    level.difficulty = int(raw.get("difficulty", 1))
    level.tutorial = bool(raw.get("tutorial", false))
    level.pattern = str(raw.get("pattern", "basic"))
    level.slope_count = maxi(2, int(raw.get("slope_count", 2)))

    var start: Dictionary = raw.get("start", {})
    level.start_position = Vector2(float(start.get("x", 150)), float(start.get("y", 150)))
    var goal: Dictionary = raw.get("goal", {})
    level.goal_position = Vector2(float(goal.get("x", 1080)), float(goal.get("y", 500)))
    level.goal_radius = float(goal.get("radius", 48))

    var raw_inventory: Dictionary = raw.get("inventory", {})
    if raw_inventory.is_empty(): level.generate_inventory()
    else:
        for kind in raw_inventory: level.inventory[str(kind)] = maxi(0, int(raw_inventory[kind]))

    var raw_pieces: Array = raw.get("pieces", [])
    for item in raw_pieces:
        if item is Dictionary:
            level.pieces.append({"type":str(item.get("type","")),"x":float(item.get("x",0)),"y":float(item.get("y",0)),"r":float(item.get("r",0))})

    var raw_solution: Array = raw.get("solution", [])
    for item in raw_solution:
        if item is Dictionary:
            level.solution_pieces.append({"type":str(item.get("type","")),"x":float(item.get("x",0)),"y":float(item.get("y",0)),"r":float(item.get("r",0))})
    if level.solution_pieces.is_empty(): level.generate_solution()
    return level

func generate_pattern() -> void:
    pieces.clear()
    solution_pieces.clear()
    generate_inventory()
    generate_solution()

func generate_inventory() -> void:
    inventory = {"board":3,"slope":slope_count}
    match pattern:
        "basic": pass
        "step": pass
        "spring": inventory["spring"] = 1
        "switch":
            inventory["switch"] = 1
            inventory["spring"] = 1
        "gear":
            inventory["switch"] = 1
            inventory["gear"] = 1
            inventory["spring"] = 1
        "rope":
            inventory["rope"] = 1
            inventory["scissors"] = 1
        "air": inventory["balloon"] = 1
        "magnet": inventory["magnet"] = 1
        "bomb": inventory["bomb"] = 1
        "combo":
            inventory["switch"] = 1
            inventory["gear"] = 1
            inventory["magnet"] = 1
            inventory["bomb"] = 1

func generate_solution() -> void:
    solution_pieces.clear()
    var count := clampi(slope_count, 2, 5)
    for i in range(count):
        var x := 200.0 + 150.0 * float(i)
        var y := 220.0 + 55.0 * float(i)
        solution_pieces.append({"type":"slope","x":x,"y":y,"r":0.22})

    var last_x := 200.0 + 150.0 * float(count - 1)
    var last_y := 220.0 + 55.0 * float(count - 1)
    var board2_x := 730.0 if count == 2 else 850.0
    var board_positions := [
        Vector2(last_x + 150.0, clampf(last_y + 90.0, 340.0, 470.0)),
        Vector2(board2_x, clampf(last_y + 140.0, 400.0, 500.0)),
        Vector2(1030.0, 500.0)
    ]
    var boards_to_use := 3 if count <= 4 else 2
    for i in range(boards_to_use):
        solution_pieces.append({"type":"board","x":board_positions[i].x,"y":board_positions[i].y,"r":0.02})

func to_dict() -> Dictionary:
    var out: Dictionary = {"id":id,"title":title,"difficulty":difficulty,"tutorial":tutorial,"pattern":pattern,"slope_count":slope_count,"start":{"x":start_position.x,"y":start_position.y},"goal":{"x":goal_position.x,"y":goal_position.y,"radius":goal_radius},"inventory":inventory.duplicate(true),"pieces":[],"solution":[]}
    for p in pieces: out["pieces"].append(p.duplicate(true))
    for p in solution_pieces: out["solution"].append(p.duplicate(true))
    return out

func duplicate_level() -> LevelData:
    var out := LevelData.new()
    out.id = id
    out.title = title
    out.difficulty = difficulty
    out.tutorial = tutorial
    out.pattern = pattern
    out.slope_count = slope_count
    out.start_position = start_position
    out.goal_position = goal_position
    out.goal_radius = goal_radius
    out.inventory = inventory.duplicate(true)
    for p in pieces: out.pieces.append(p.duplicate(true))
    for p in solution_pieces: out.solution_pieces.append(p.duplicate(true))
    return out

func with_solution_layout() -> LevelData:
    var out := duplicate_level()
    out.pieces.clear()
    for p in solution_pieces: out.pieces.append(p.duplicate(true))
    return out
