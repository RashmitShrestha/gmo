class_name Seed
extends RigidBody2D

@export var lifetime: float

func _ready() -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.start(lifetime)
	timer.timeout.connect(func(): queue_free())
	
	$Area2D.body_entered.connect(
		func(_body: Node2D):
			if _body is Warden or _body is PeachTree:
				queue_free()
	)
