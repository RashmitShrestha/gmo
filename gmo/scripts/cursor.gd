extends Area2D

var _speed: float
@onready var _warden: Warden = %Warden

func _ready() -> void:
	position = get_global_mouse_position()
	
	body_entered.connect(
		func(body: Node2D):
			if (position - _warden.position).length() < _warden.slice_radius:
				if body is Fruit:
					body.apply_damage(_speed, self)
	)


func _physics_process(_delta: float) -> void:
	_speed = (position - get_global_mouse_position()).length()
	position = get_global_mouse_position()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		monitoring = true
	elif Input.is_action_just_released("left_click"):
		monitoring = false
