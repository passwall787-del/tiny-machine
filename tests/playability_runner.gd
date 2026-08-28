extends SceneTree

var failures: Array[String] = []
var game
const REQUIRED_LEVELS := 32
const TEST_TIME_SCALE := 4.0
const TEST_TIMEOUT := 8.0
const MAX_FRAMES_PER_LEVEL := 240

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene = load("res://main.tscn")
    if scene == null or not scene is PackedScene or not scene.can_instantiate():
        failures.append("main scene unavailable")
        _finish(0)
        return

    game = scene.instantiate()
    get_root().add_child(game)
    await process_frame
    await process_frame
    await process_frame

    var level_count: int = int(game.levels.size())
    if level_count != REQUIRED_LEVELS:
        failures.append("playability runner expected %d levels, loaded %d" % [REQUIRED_LEVELS, level_count])
        await _cleanup()
        _finish(level_count)
        return

    Engine.time_scale = TEST_TIME_SCALE

    for index in range(level_count):
        game._load_level(index)
        game.run_timeout = TEST_TIMEOUT
        game._prepare_test_solution()
        if game.runtime.components.is_empty():
            failures.append("level %02d test solution did not place any components" % [index + 1])
            continue
        game.toggle_run()
        var frames := 0
        while game.state == 1 and frames < MAX_FRAMES_PER_LEVEL:
            await physics_frame
            await process_frame
            frames += 1

        if game.state != 3:
            var pos := Vector2.ZERO
            if game.runtime != null and game.runtime.ball != null:
                pos = game.runtime.ball.global_position
            failures.append("level %02d test solution did not reach SUCCESS (state=%s, frames=%d, elapsed=%.2f, ball=%s)" % [index + 1, str(game.state), frames, game.elapsed, str(pos)])
        else:
            await process_frame

    await _cleanup()
    _finish(level_count)

func _cleanup() -> void:
    Engine.time_scale = 1.0
    if game != null and is_instance_valid(game):
        game.queue_free()
        await process_frame

func _finish(level_count: int) -> void:
    if failures.is_empty():
        print("Tiny Machine constructed-solution playability test: PASS (%d levels)" % level_count)
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        print("Tiny Machine constructed-solution playability test: FAIL (%d)" % failures.size())
        quit(1)
