extends Node
class_name AudioManager

var player: AudioStreamPlayer
var stream: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback
var music_timer: Timer
var music_enabled := true
var note_index := 0
const NOTES := [261.63, 329.63, 392.00, 329.63, 293.66, 349.23, 440.00, 349.23]

func _ready() -> void:
    stream = AudioStreamGenerator.new()
    stream.mix_rate = 22050
    stream.buffer_length = 0.35
    player = AudioStreamPlayer.new()
    player.stream = stream
    player.volume_db = -12.0
    add_child(player)
    player.play()
    playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
    music_timer = Timer.new()
    music_timer.wait_time = 0.42
    music_timer.autostart = true
    music_timer.timeout.connect(_music_tick)
    add_child(music_timer)

func set_enabled(enabled: bool) -> void:
    music_enabled = enabled
    if player:
        player.volume_db = -12.0 if enabled else -80.0

func _music_tick() -> void:
    if not music_enabled:
        return
    _push_tone(NOTES[note_index % NOTES.size()], 0.18, 0.018)
    note_index += 1

func success() -> void:
    _push_tone(523.25, 0.10, 0.06)
    _push_tone(659.25, 0.12, 0.06)
    _push_tone(783.99, 0.20, 0.07)

func failure() -> void:
    _push_tone(220.0, 0.14, 0.05)
    _push_tone(164.81, 0.22, 0.05)

func click() -> void:
    _push_tone(880.0, 0.035, 0.025)

func _push_tone(frequency: float, duration: float, amplitude: float) -> void:
    if playback == null or not music_enabled:
        return
    var frames := maxi(1, int(stream.mix_rate * duration))
    var buffer := PackedVector2Array()
    buffer.resize(frames)
    for i in range(frames):
        var t := float(i) / float(stream.mix_rate)
        var envelope := 1.0 - float(i) / float(frames)
        var sample := sin(TAU * frequency * t) * amplitude * envelope
        buffer[i] = Vector2(sample, sample)
    playback.push_buffer(buffer)
