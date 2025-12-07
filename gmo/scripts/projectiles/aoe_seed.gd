class_name AOESeed
extends RigidBody2D

@export var lifetime: float
var spawner: Banana
@onready var _splash: PackedScene = preload("res://scenes/splash.tscn")

func _ready() -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.start(lifetime)
	timer.timeout.connect(func(): queue_free())
	
	$Area2D.body_entered.connect(
		func(body: Node2D):
			if body != spawner:
				var splash: Splash = _splash.instantiate()
				splash.position = position
				get_tree().root.add_child(splash)
				queue_free()
	)
