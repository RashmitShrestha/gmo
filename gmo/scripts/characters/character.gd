class_name GameCharacter
extends CharacterBody2D

# Keep received_damage as a local signal for components that need it
signal received_damage(damage, _source)

@export var speed: float
var base_speed: float
var direction := Vector2.ZERO
var id : int
@export var max_health : float
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var curr_health : float = max_health

const DAMAGE_NUMBER = preload("res://scenes/ui/damage_number.tscn")

var damaged: bool = false
var invulnerable: bool = false

var dot_effects := {
	1: {"dps": 0.0, "time": 0.0, "active": false, "tot_dmg": 0.0},
	2: {"dps": 0.0, "time": 0.0, "active": false, "slow_multiplier": 1.0, "tot_dmg": 0.0},
	3: {"dps": 0.0, "time": 0.0, "active": false, "lifesteal_source": null, "tot_dmg": 0.0}
}

var element_colors = {
	0: Color(1.0, 1.0, 1.0),
	1: Color(1.0, 0.3, 0.2),
	2: Color(0.3, 0.6, 1.0),
	3: Color(0.7, 1.0, 0.3)
}

var dot_damage_number_timer := 0.0
var dot_damage_number_interval := 1.0

var heal_number_timer := 0.0
var heal_number_interval := 1.0
var accumulated_heal := 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	base_speed = speed

func _physics_process(_delta: float) -> void:
	move_and_slide()
	
	if get_slide_collision_count():
		velocity = Vector2.ZERO
	
	_process_dot_effects(_delta)
	_process_heal_numbers(_delta)

func apply_damage(damage: float, _source: Node2D, element: int = 0, is_dot: bool = false):
	if invulnerable:
		return
	
	var final_damage = damage
	if self is Fruit and element > 0:
		var multiplier = ElementSystem.element_mult(element, self.element)
		final_damage = damage * multiplier
	
	curr_health -= final_damage
	damaged = true
	
	# Only spawn damage number if NOT from DOT
	if not is_dot:
		spawn_damage_number(final_damage, element)
		print(final_damage)
		
	#if self is Warden:
		#print("WARDEN SAYS HI")
		#print(curr_health)
	
	if curr_health < 0.0:
		curr_health = 0.0
	
	#print(self)
	
	received_damage.emit(final_damage, _source)


func heal(amount: float) -> void:
	if amount <= 0:
		return
		
	var old_health = curr_health
	curr_health = min(curr_health + amount, max_health)
	var actual_heal = curr_health - old_health
	
	if actual_heal > 0:
		# Accumulate heal instead of spawning immediately
		accumulated_heal += actual_heal
		# Only emit through SignalBus (no local signal)
		SignalBus.health_restored.emit(self, actual_heal)

func _process_heal_numbers(delta: float) -> void:
	heal_number_timer += delta
	
	if heal_number_timer >= heal_number_interval:
		heal_number_timer = 0.0
		
		if accumulated_heal >= 0.5:
			spawn_heal_number(accumulated_heal)
			accumulated_heal = 0.0

func spawn_damage_number(damage: float, element: int = 0) -> void:
	if damage < 0.5:  # Don't show tiny damage
		return
		
	var damage_number = DAMAGE_NUMBER.instantiate()
	get_parent().add_child(damage_number)
	damage_number.global_position = global_position + Vector2(0, -30)
	damage_number.z_index = 100
	
	var color = element_colors.get(element, Color.WHITE)
	# Use ceil to round up so we never show 0
	damage_number.set_damage(ceili(damage), color)

func spawn_heal_number(heal_amount: float) -> void:
	if heal_amount < 0.5:
		return
		
	var damage_number = DAMAGE_NUMBER.instantiate()
	get_parent().add_child(damage_number)
	damage_number.global_position = global_position + Vector2(0, -30)
	damage_number.z_index = 100
	damage_number.set_heal(ceili(heal_amount))

func _die():
	print(str(self) + " has been defeated!")

	if has_meta("enemy_name"):
		var enemy_name = get_meta("enemy_name", "Unknown")
		var drop_type = 0
		SignalBus.enemy_died.emit(enemy_name, self, drop_type)

	queue_free()

func _process_dot_effects(delta: float) -> void:
	dot_damage_number_timer += delta
	var should_spawn_damage_number = dot_damage_number_timer >= dot_damage_number_interval
	
	if should_spawn_damage_number:
		dot_damage_number_timer = 0.0
	
	for element in dot_effects.keys():
		var effect = dot_effects[element]
		
		if effect.time > 0:
			var damage_this_frame = effect.dps * delta
			
			# Apply element multiplier for DoT
			var final_damage = damage_this_frame
			if self is Fruit and element > 0:
				var multiplier = ElementSystem.element_mult(element, self.element)
				final_damage = damage_this_frame * multiplier
			
			# Just reduce health directly, don't call apply_damage
			curr_health -= final_damage
			effect.tot_dmg += final_damage
			
			# Handle lifesteal for ferment
			if element == 3 and effect.has("lifesteal_source") and is_instance_valid(effect.lifesteal_source):
				var lifesteal_amount = ceil(final_damage * 0.5)
				effect.lifesteal_source.heal(lifesteal_amount)
			
			received_damage.emit(final_damage, self)
			
			effect.time -= delta
			
			# Check for death
			if curr_health <= 0:
				curr_health = 0.0
				if effect.tot_dmg >= 0.5:
					spawn_damage_number(effect.tot_dmg, element)
				_die()
				return
			
			# DOT expired
			if effect.time <= 0:
				if effect.tot_dmg >= 0.5:
					spawn_damage_number(effect.tot_dmg, element)
				effect.tot_dmg = 0.0
				_clear_effect(element)
	
	# Show accumulated DOT damage every interval
	if should_spawn_damage_number:
		for element in dot_effects.keys():
			var effect = dot_effects[element]
			if effect.tot_dmg >= 0.5:
				spawn_damage_number(effect.tot_dmg, element)
				effect.tot_dmg = 0.0


func _clear_effect(element: int) -> void:
	if element in dot_effects:
		dot_effects[element].dps = 0.0
		dot_effects[element].time = 0.0
		dot_effects[element].active = false
		dot_effects[element].tot_dmg = 0.0
		
		if element == 2:
			dot_effects[element].slow_multiplier = 1.0
			_update_speed()
		
		if element == 3:
			dot_effects[element].lifesteal_source = null

func apply_dot(element: int, dps: float, duration: float, lifesteal_source = null) -> void:
	print("\n=== APPLY_DOT CALLED ===")
	print("Character: ", name)
	print("Element: ", element)
	print("DPS: ", dps)
	print("Duration: ", duration)
	print("Lifesteal source: ", lifesteal_source.name if lifesteal_source else "None")
	
	if element in dot_effects:
		dot_effects[element].dps = dps
		dot_effects[element].time = duration
		dot_effects[element].active = true
		
		print("DOT effect set: ", dot_effects[element])
		
		if element == 2:
			dot_effects[element].slow_multiplier = 0.5
			_update_speed()
			print("Applied frost slow")
		
		if element == 3 and lifesteal_source:
			dot_effects[element].lifesteal_source = lifesteal_source
			print("Applied lifesteal source")
		
		print("========================\n")

func _update_speed() -> void:
	var slowest = 1.0
	for element in dot_effects.keys():
		if dot_effects[element].active and dot_effects[element].has("slow_multiplier"):
			slowest = min(slowest, dot_effects[element].slow_multiplier)
	
	speed = base_speed * slowest
	push_warning(speed)
	push_warning(base_speed)

func clear_dot(element: int) -> void:
	_clear_effect(element)

func clear_all_dots() -> void:
	for element in dot_effects.keys():
		_clear_effect(element)

func get_active_dots() -> Array:
	var active = []
	for element in dot_effects.keys():
		if dot_effects[element].time > 0:
			active.append(element)
	return active
