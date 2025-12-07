class_name Seed
extends RigidBody2D

@export var damage: float
@export var lifetime: float

func _ready() -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.start(lifetime)
	timer.timeout.connect(func(): queue_free())
	
	$Area2D.body_entered.connect(
		func(_body: Node2D):
			if _body is Warden:
				var warden: Warden = _body as Warden
				warden.apply_damage(damage, self)
			elif _body is PeachTree:
				var tree: PeachTree = _body as PeachTree
				tree.apply_damage(damage, self)
			
			queue_free()
	)
