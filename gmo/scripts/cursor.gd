extends Area2D


func _ready() -> void:
	body_entered.connect(
		func(body: Node2D):
			body.apply_damage(10.0, self)
	)


func _process(_delta: float) -> void:
	position = get_global_mouse_position()

	if Input.is_action_just_pressed("left_click"):
		monitoring = true
	elif Input.is_action_just_released("left_click"):
		monitoring = false
