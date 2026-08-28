extends SceneTree

var failures: Array[String] = []
var game

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene = load("res://main.tscn")
    if scene == null or not scene is PackedScene or not scene.can_instantiate():
        failures.append("main scene unavailable")
        _finish()
        return
    game = scene.instantiate()
    get_root().add_child(game)
    await process_frame
    Engine.time_scale = 6.0
    for index in range(game.levels.size()):
        game._load_level(index)
        game.run_timeout = 4.0
        game.toggle_run()
        var frames := 0
        while game.state == 1 and frames < 180:
            await process_frame
            frames += 1
        if game.state != 3:
            var pos := Vector2.ZERO
            if game.runtime != null and game.runtime.ball != null: pos = game.runtime.ball.global_position
            failures.append("level %02d default layout did not reach SUCCESS (state=%s, frames=%d, elapsed=%.2f, ball=%s)" % [index + 1, str(game.state), frames, game.elapsed, str(pos)])
        else:
            await process_frame
    Engine.time_scale = 1.0
    game.queue_free()
    await process_frame
    _finish()

func _finish() -> void:
    if failures.is_empty():
        print("Tiny Machine default-level playability test: PASS (%d levels)" % (game.levels.size() if game != null else 0))
        quit(0)
    else:
        for failure in failures: push_error(failure)
        print("Tiny Machine default-level playability test: FAIL (%d)" % failures.size())
        quit(1)
