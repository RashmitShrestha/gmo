class_name Seed
extends RigidBody2D

@export var lifetime: float

func _ready() -> void:
	var timer := Timer.new()
	timer.one_shot = true
	timer.start(lifetime)
	timer.timeout.connect(func(): queue_free())
	
	$Area2D.area_entered.connect(
		func(_area: Area2D):
			if _area.get_parent().name == "Warden":
				queue_free()
	)
