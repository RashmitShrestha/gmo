class_name GameCharacter
extends CharacterBody2D

@export var speed: float
var direction := Vector2.ZERO
var id : int
var health : float

var damaged: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		velocity = Vector2.ZERO
