class_name GameCharacter
extends CharacterBody2D

signal received_damage(damage, _source)

@export var speed: float
var direction := Vector2.ZERO
var id : int
@export var max_health : float
var curr_health : float = max_health

var damaged: bool = false
var invulnerable: bool = false

var dot_effects := {
	1: {"dps": 0.0, "time": 0.0},  # Fire
	2: {"dps": 0.0, "time": 0.0},  # Frozen
	3: {"dps": 0.0, "time": 0.0}   # Ferment
}

@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(_delta: float) -> void:
	move_and_slide()
	
	if get_slide_collision_count():
		velocity = Vector2.ZERO
	
	_process_dot_effects(_delta)


func apply_damage(damage: float, _source: Node2D):
	if invulnerable:
		return
	
	damaged = true
	received_damage.emit(damage, _source)

func _die():
	print(str(self) + " has been defeated!")
	
	'''
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	'''
	
	queue_free()

func _process_dot_effects(delta: float) -> void:
	for element in dot_effects.keys():
		var effect = dot_effects[element]
		
		if effect.time > 0:
			# Apply damage
			var damage_this_frame = effect.dps * delta
			curr_health -= damage_this_frame
			received_damage.emit(damage_this_frame, self)
			
			# Decrease remaining time
			effect.time -= delta
			
			# Clean up expired effect
			if effect.time <= 0:
				effect.dps = 0.0
				effect.time = 0.0
	
func apply_dot(element: int, dps: float, duration: float) -> void:
	if element in dot_effects:
		dot_effects[element].damage_per_second += dps  
		dot_effects[element].remaining_time = max(dot_effects[element].remaining_time, duration)

func clear_dot(element: int) -> void:
	if element in dot_effects:
		dot_effects[element].damage_per_second = 0.0
		dot_effects[element].remaining_time = 0.0

func clear_all_dots() -> void:
	for element in dot_effects.keys():
		clear_dot(element)

func get_active_dots() -> Array:
	var active = []
	for element in dot_effects.keys():
		if dot_effects[element].remaining_time > 0:
			active.append(element)
	return active
