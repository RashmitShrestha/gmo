class_name GameCharacter
extends CharacterBody2D

signal received_damage(damage, _source)

@export var speed: float
var direction := Vector2.ZERO
var id : int
var max_health : float
var curr_health : float

var damaged: bool = false
var invulnerable: bool = false


@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(_delta: float) -> void:
	move_and_slide()
	
	if get_slide_collision_count():
		velocity = Vector2.ZERO


func apply_damage(damage: float, _source: Node):
	if invulnerable:
		return
	
	received_damage.emit(damage, _source)
