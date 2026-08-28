extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    _test_scripts_parse()
    _test_level_catalog()
    _test_level_serialization()
    _test_validator()
    if failures.is_empty():
        print("Tiny Machine automated tests: PASS")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        print("Tiny Machine automated tests: FAIL (%d)" % failures.size())
        quit(1)

func _test_scripts_parse() -> void:
    var scripts := ["main.gd","machine_component.gd","component_factory.gd","level_runtime.gd","level_data.gd","level_validator.gd","audio_manager.gd"]
    for path in scripts:
        var resource = load("res://" + path)
        if resource == null or not resource is GDScript or not resource.can_instantiate():
            failures.append("script failed to parse/instantiate: %s" % path)

func _test_level_catalog() -> void:
    var path := "res://levels.json"
    if not FileAccess.file_exists(path):
        failures.append("levels.json does not exist")
        return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if not parsed is Dictionary:
        failures.append("levels.json root is not an object")
        return
    var raw_levels: Array = parsed.get("levels", [])
    if raw_levels.size() < 30: failures.append("official level count is %d, expected at least 30" % raw_levels.size())
    var seen := {}
    for raw in raw_levels:
        if not raw is Dictionary:
            failures.append("level entry is not an object")
            continue
        var level := LevelData.from_dict(raw)
        if seen.has(level.id): failures.append("duplicate level id %d" % level.id)
        seen[level.id] = true
        var validation := LevelValidator.validate(level)
        if not validation.ok: failures.append("level %d invalid: %s" % [level.id, "; ".join(validation.errors)])
        var balls := 0
        for piece in level.pieces:
            if str(piece.get("type", "")) == "ball": balls += 1
        if balls != 1: failures.append("level %d must contain exactly one ball" % level.id)

func _test_level_serialization() -> void:
    var level := LevelData.new()
    level.id = 999
    level.title = "roundtrip"
    level.difficulty = 3
    level.pattern = "combo"
    level.slope_count = 4
    level.generate_pattern()
    var restored := LevelData.from_dict(level.to_dict())
    if restored.id != level.id or restored.pieces.size() != level.pieces.size(): failures.append("LevelData serialization roundtrip failed")

func _test_validator() -> void:
    var bad := LevelData.new()
    bad.goal_position = Vector2(-10, -10)
    bad.pieces = [{"type":"unknown","x":100,"y":100,"r":0}]
    var result := LevelValidator.validate(bad)
    if result.ok: failures.append("validator accepted an invalid level")
