extends RefCounted
class_name LevelData

var id: int = 0
var title: String = ""
var difficulty: int = 1
var tutorial: bool = false
var pattern: String = "basic"
var slope_count: int = 3
var goal_position := Vector2(1130, 620)
var goal_radius: float = 48.0
var pieces: Array[Dictionary] = []

static func from_dict(raw: Dictionary) -> LevelData:
    var level := LevelData.new()
    level.id = int(raw.get("id", 0))
    level.title = str(raw.get("title", "未命名关卡"))
    level.difficulty = int(raw.get("difficulty", 1))
    level.tutorial = bool(raw.get("tutorial", false))
    level.pattern = str(raw.get("pattern", "basic"))
    level.slope_count = int(raw.get("slope_count", 3))
    var goal: Dictionary = raw.get("goal", {})
    level.goal_position = Vector2(float(goal.get("x", 1130)), float(goal.get("y", 620)))
    level.goal_radius = float(goal.get("radius", 48))
    var raw_pieces: Array = raw.get("pieces", [])
    for item in raw_pieces:
        if item is Dictionary:
            level.pieces.append({"type":str(item.get("type","")),"x":float(item.get("x",0)),"y":float(item.get("y",0)),"r":float(item.get("r",0))})
    if level.pieces.is_empty(): level.generate_pattern()
    return level

func generate_pattern() -> void:
    pieces.clear()
    pieces.append({"type":"ball","x":300.0,"y":180.0,"r":0.0})
    var count: int = 5
    for i in range(count):
        pieces.append({"type":"slope","x":320.0 + i * 190.0,"y":230.0 + i * 95.0,"r":0.30})
    pieces.append({"type":"board","x":1135.0,"y":665.0,"r":0.0})
    match pattern:
        "step":
            pieces.append({"type":"board","x":690.0,"y":650.0,"r":0.0})
        "spring":
            pieces.append({"type":"spring","x":760.0,"y":620.0,"r":0.0})
        "switch":
            pieces.append({"type":"switch","x":680.0,"y":640.0,"r":0.0})
            pieces.append({"type":"spring","x":840.0,"y":640.0,"r":0.0})
        "gear":
            pieces.append({"type":"switch","x":680.0,"y":640.0,"r":0.0})
            pieces.append({"type":"gear","x":900.0,"y":640.0,"r":0.0})
            pieces.append({"type":"spring","x":1020.0,"y":640.0,"r":0.0})
        "rope":
            pieces.append({"type":"rope","x":430.0,"y":625.0,"r":0.0})
            pieces.append({"type":"scissors","x":560.0,"y":625.0,"r":0.0})
        "air":
            pieces.append({"type":"balloon","x":1020.0,"y":300.0,"r":0.0})
        "magnet":
            pieces.append({"type":"magnet","x":1020.0,"y":640.0,"r":0.0})
        "bomb":
            pieces.append({"type":"bomb","x":980.0,"y":640.0,"r":0.0})
        "combo":
            pieces.append({"type":"switch","x":680.0,"y":640.0,"r":0.0})
            pieces.append({"type":"gear","x":900.0,"y":640.0,"r":0.0})
            pieces.append({"type":"magnet","x":1000.0,"y":640.0,"r":0.0})
            pieces.append({"type":"bomb","x":930.0,"y":640.0,"r":0.0})

func to_dict() -> Dictionary:
    var out: Dictionary = {"id":id,"title":title,"difficulty":difficulty,"tutorial":tutorial,"pattern":pattern,"slope_count":slope_count,"goal":{"x":goal_position.x,"y":goal_position.y,"radius":goal_radius},"pieces":[]}
    for p in pieces: out["pieces"].append(p.duplicate(true))
    return out

func duplicate_level() -> LevelData:
    return LevelData.from_dict(to_dict())
