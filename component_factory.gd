extends RefCounted
class_name ComponentFactory

static func create_component(kind: String, data: Dictionary, owner: Node, editor: Node) -> MachineComponent:
    var body: Node2D
    match kind:
        "ball", "balloon":
            body = RigidBody2D.new()
            var rb := body as RigidBody2D
            rb.freeze = true
            rb.mass = 1.0 if kind == "ball" else 0.8
            rb.gravity_scale = 1.0 if kind == "ball" else -0.22
            rb.linear_damp = 0.08
            rb.angular_damp = 0.08
            rb.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
        "gear":
            body = AnimatableBody2D.new()
        "magnet", "switch", "spring", "rope", "scissors", "bomb":
            body = Area2D.new()
        "board", "slope":
            body = StaticBody2D.new()
        _:
            return null

    body.set_script(load("res://machine_component.gd"))
    var piece := body as MachineComponent
    if piece == null:
        return null
    piece.setup(kind, owner, editor, Vector2(float(data.get("x", 600)), float(data.get("y", 330))), float(data.get("r", 0)))

    var node: Node = piece
    if not node is CollisionObject2D:
        return null
    var collider: CollisionObject2D = node
    var solid := kind in ["ball", "balloon", "board", "slope", "gear"]
    if solid:
        collider.collision_layer = 1
        collider.collision_mask = 1
    else:
        collider.collision_layer = 2
        collider.collision_mask = 0

    if kind == "slope":
        var poly := CollisionPolygon2D.new()
        poly.polygon = PackedVector2Array([Vector2(-125, 22), Vector2(125, -22), Vector2(125, 22)])
        piece.add_child(poly)
    else:
        var shape := CollisionShape2D.new()
        match kind:
            "ball":
                var ball_shape := CircleShape2D.new()
                ball_shape.radius = 24.0
                shape.shape = ball_shape
            "balloon":
                var balloon_shape := CircleShape2D.new()
                balloon_shape.radius = 28.0
                shape.shape = balloon_shape
            "gear":
                var gear_shape := CircleShape2D.new()
                gear_shape.radius = 42.0
                shape.shape = gear_shape
            "board":
                var board_shape := RectangleShape2D.new()
                board_shape.size = Vector2(250, 30)
                shape.shape = board_shape
            "magnet":
                var magnet_shape := CircleShape2D.new()
                magnet_shape.radius = 72.0
                shape.shape = magnet_shape
            "bomb":
                var bomb_shape := CircleShape2D.new()
                bomb_shape.radius = 58.0
                shape.shape = bomb_shape
            "spring":
                var spring_shape := RectangleShape2D.new()
                spring_shape.size = Vector2(110, 26)
                shape.shape = spring_shape
            "rope":
                var rope_shape := RectangleShape2D.new()
                rope_shape.size = Vector2(180, 20)
                shape.shape = rope_shape
            "scissors":
                var scissors_shape := RectangleShape2D.new()
                scissors_shape.size = Vector2(96, 34)
                shape.shape = scissors_shape
            "switch":
                var switch_shape := RectangleShape2D.new()
                switch_shape.size = Vector2(110, 28)
                shape.shape = switch_shape
        piece.add_child(shape)

    owner.add_child(piece)
    return piece
