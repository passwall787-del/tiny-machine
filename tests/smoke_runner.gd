extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run_smoke")

func _run_smoke() -> void:
    var scene = load("res://main.tscn")
    if scene == null or not scene is PackedScene or not scene.can_instantiate():
        failures.append("main.tscn cannot be instantiated")
    else:
        var game = scene.instantiate()
        get_root().add_child(game)
        await process_frame
        await process_frame
        await process_frame
        if game.runtime == null: failures.append("LevelRuntime was not initialized")
        if game.levels.size() < 32: failures.append("main loaded fewer than 32 levels")
        if game.runtime == null or game.runtime.ball == null: failures.append("first level has no runtime ball")
        if game.runtime == null or game.runtime.goal == null: failures.append("first level has no goal")
        if game.state != 0: failures.append("game did not start in EDITING state")
        if failures.is_empty():
            game.toggle_run()
            if game.state != 1: failures.append("toggle_run did not enter RUNNING")
            else:
                game._on_goal_body_entered(game.runtime.ball)
                if game.state != 3: failures.append("goal entry did not enter SUCCESS")
        game.queue_free()
    if failures.is_empty():
        print("Tiny Machine runtime smoke test: PASS")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        print("Tiny Machine runtime smoke test: FAIL (%d)" % failures.size())
        quit(1)
