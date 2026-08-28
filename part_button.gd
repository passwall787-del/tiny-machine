extends Button
class_name PartButton

var piece_kind := ""
var piece_title := ""
var available_count := 0
var accent_color := Color("#6db8ff")

func setup(kind: String, title: String, count: int, color: Color) -> void:
    piece_kind = kind
    piece_title = title
    available_count = count
    accent_color = color
    text = ""
    focus_mode = Control.FOCUS_NONE
    mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    queue_redraw()

func set_count(count: int) -> void:
    available_count = count
    disabled = count <= 0
    queue_redraw()

func _draw() -> void:
    var w := size.x
    var h := size.y
    var disabled_alpha := 0.42 if available_count <= 0 else 1.0
    var center := Vector2(w * 0.5, 42)
    var c := Color(accent_color.r, accent_color.g, accent_color.b, disabled_alpha)

    draw_circle(center + Vector2(0, 2), 27, Color(0, 0, 0, 0.18 * disabled_alpha))
    _draw_icon(piece_kind, center, c)

    draw_string(ThemeDB.fallback_font, Vector2(8, 83), piece_title, HORIZONTAL_ALIGNMENT_CENTER, w - 16, 13, Color(0.94, 0.97, 1.0, disabled_alpha))
    var pill := Rect2(w - 34, 8, 26, 20)
    draw_style_box(_pill_style(c, disabled_alpha), pill)
    draw_string(ThemeDB.fallback_font, Vector2(w - 31, 23), str(available_count), HORIZONTAL_ALIGNMENT_CENTER, 20, 12, Color("#08111b"))

func _pill_style(c: Color, alpha: float) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = Color(c.r, c.g, c.b, 0.95 * alpha)
    s.set_corner_radius_all(8)
    return s

func _draw_icon(kind: String, p: Vector2, c: Color) -> void:
    match kind:
        "board":
            draw_rect(Rect2(p + Vector2(-29, -7), Vector2(58, 14)), c, true)
            draw_rect(Rect2(p + Vector2(-29, -7), Vector2(58, 14)), Color("#5a341d"), false, 2)
            draw_line(p + Vector2(-18, -1), p + Vector2(18, -1), Color(1, 1, 1, 0.25), 2)
        "slope":
            var poly := PackedVector2Array([p + Vector2(-30, 11), p + Vector2(30, -11), p + Vector2(30, 11)])
            draw_colored_polygon(poly, c)
            draw_polyline(poly, Color("#5a341d"), 2, true)
        "spring":
            draw_rect(Rect2(p + Vector2(-28, -8), Vector2(56, 16)), Color("#203246"), true)
            for i in range(5):
                var x := -20.0 + float(i) * 10.0
                draw_line(p + Vector2(x, 0), p + Vector2(x + 5, -8 if i % 2 == 0 else 8), c, 3, true)
        "rope":
            draw_line(p + Vector2(-28, 0), p + Vector2(28, 0), c, 6, true)
            draw_circle(p + Vector2(-28, 0), 5, c)
            draw_circle(p + Vector2(28, 0), 5, c)
        "scissors":
            draw_line(p + Vector2(-18, -13), p + Vector2(20, 13), c, 5, true)
            draw_line(p + Vector2(-18, 13), p + Vector2(20, -13), c, 5, true)
            draw_circle(p + Vector2(-21, -16), 9, Color("#f08b7f"), false, 4)
            draw_circle(p + Vector2(-21, 16), 9, Color("#f08b7f"), false, 4)
        "gear":
            draw_circle(p, 23, c)
            for i in range(10):
                var a := TAU * float(i) / 10.0
                draw_line(p + Vector2.RIGHT.rotated(a) * 20, p + Vector2.RIGHT.rotated(a) * 29, c, 6, true)
            draw_circle(p, 8, Color("#142130"))
        "switch":
            draw_rect(Rect2(p + Vector2(-27, -9), Vector2(54, 18)), Color("#25384d"), true)
            draw_circle(p + Vector2(15, 0), 7, c)
            draw_line(p + Vector2(-10, 0), p + Vector2(10, -11), c, 5, true)
        "balloon":
            draw_circle(p + Vector2(0, -4), 20, c)
            draw_circle(p + Vector2(-6, -10), 5, Color(1, 1, 1, 0.35))
            draw_line(p + Vector2(0, 16), p + Vector2(0, 31), Color("#d9e2ed"), 2)
        "magnet":
            draw_arc(p + Vector2(0, 4), 22, PI, TAU, 24, c, 8)
            draw_line(p + Vector2(-22, 4), p + Vector2(-22, -13), c, 8, true)
            draw_line(p + Vector2(22, 4), p + Vector2(22, -13), Color("#69a9ff"), 8, true)
        "bomb":
            draw_circle(p + Vector2(0, 4), 21, c)
            draw_line(p + Vector2(10, -14), p + Vector2(22, -26), Color("#f0d28b"), 5, true)
            draw_circle(p + Vector2(25, -29), 5, Color("#ffd66b"))
