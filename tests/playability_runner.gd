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
        _finish()
        return

    game = scene.instantiate()
    get_root().add_child(game)
    await process_frame
    await process_frame
    await process_frame

    if game.levels.size() != REQUIRED_LEVELS:
        failures.append("playability runner expected %d levels, loaded %d" % [REQUIRED_LEVELS, game.levels.size()])
        _cleanup_and_finish()
        return

    # Accelerate only the wall-clock test duration. The game timeout is kept
    # at 8 seconds of simulated game time, so a bad level fails quickly while
    # still exercising the normal SUCCESS/FAIL state machine.
    Engine.time_scale = TEST_TIME_SCALE

    for index in range(game.levels.size()):
        game._load_level(index)
        game.run_timeout = TEST_TIMEOUT
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
            failures.append("level %02d default layout did not reach SUCCESS (state=%s, frames=%d, elapsed=%.2f, ball=%s)" % [index + 1, str(game.state), frames, game.elapsed, str(pos)])
        else:
            await process_frame

    Engine.time_scale = 1.0
    _cleanup_and_finish()

func _cleanup_and_finish() -> void:
    Engine.time_scale = 1.0
    if game != null and is_instance_valid(game):
        game.queue_free()
        await process_frame
    _finish()

func _finish() -> void:
    if failures.is_empty():
        print("Tiny Machine default-level playability test: PASS (%d levels)" % (game.levels.size() if game != null else 0))
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        print("Tiny Machine default-level playability test: FAIL (%d)" % failures.size())
        quit(1)
