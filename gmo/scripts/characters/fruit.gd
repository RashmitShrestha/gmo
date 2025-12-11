class_name Fruit 
extends GameCharacter

var target_warden_chance: float = 0.7


var element : int = 0
var stun_time: float = 1.0
var warden: Warden
var peach_tree: PeachTree
var target: GameCharacter
var stunned: bool = false
var dead: bool = false
var is_attacking: bool = false
var fertilized : bool = false
var elem_speed_mult : float = 1.0

var global_slow_modifier: float = 1.0
var frost_trail_modifier: float = 1.0
var frost_timer : Timer

# fertilized farm variables
var ally_spawn_active: bool = false
var ally_lifetime: float = 0.0
var stat_boost: float = 1.0

var is_burned: bool = false
var burn_timer: Timer
var stun_timer: Timer

var elemParticle: CPUParticles2D


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var attack_area: Area2D = $Area2D

var attack_cooldown: float = 0.0
var attack_rate: float = 1.0 
var attack_damage: float = 10.0



func _physics_process(_delta: float) -> void:
	if attack_cooldown > 0:
		attack_cooldown -= _delta
		
	if fertilized and ally_lifetime > 0:
		ally_lifetime -= _delta
		if ally_lifetime <= 0:
			dead = true
			animation_tree.active = false
			animation_player.play("death")
			return

	if not fertilized and target == peach_tree and peach_tree and peach_tree.is_dead:
		target = warden

	if stunned or dead:
		velocity = Vector2.ZERO
		move_and_slide()
		
		if stunned and not dead:
			$FreezeFrameParticle.emitting = true
			$FreezeFrameParticle.visible = true
		else:
			$FreezeFrameParticle.emitting = false
			$FreezeFrameParticle.visible = false
		
		return

		
	$FreezeFrameParticle.emitting = false
	$FreezeFrameParticle.visible = false

	if fertilized:
		_update_fertilized_target()

		
	var speed_mult = global_slow_modifier * frost_trail_modifier * elem_speed_mult
	
	if speed_mult != 1.0:
		velocity *= speed_mult
		
	super._physics_process(_delta)
	
	if speed_mult != 1.0:
		velocity /= speed_mult
		
	if dead:
		return
	
	_face_target()

func _ready():
	match element:
		1: 	
			elemParticle = $FlameParticle

		2:
			elemParticle = $FrozenParticle
			elem_speed_mult = 1.3
		3:
			elemParticle = $FermentParticle
			max_health *= 2
			curr_health = max_health
		
			
	if element != 0:
		elemParticle.emitting = true
		elemParticle.visible = true
	
	add_to_group("enemies")
	super._ready()

	SignalBus.player_died.connect(func(): target = peach_tree)
	SignalBus.tree_died.connect(func(): target = warden)
	SignalBus.stat_modified.connect(_on_stat_modified)
	SignalBus.status_effect_applied.connect(_on_status_effect_applied)

	
	animation_tree.active = true
	animation_player.animation_finished.connect(_on_death)
	
	if warden == null:
		warden = get_node_or_null("%Warden")
		if warden == null:
			warden = get_parent().get_node_or_null("Warden") if get_parent() else null
	if peach_tree == null:
		peach_tree = get_node_or_null("%PeachTree")
		if peach_tree == null:
			peach_tree = get_parent().get_node_or_null("PeachTree") if get_parent() else null

	if peach_tree and peach_tree.is_dead:
		target = warden
	elif randf() < target_warden_chance:
		target = warden
	else:
		target = peach_tree

	SignalBus.damage_enemy.connect(_on_damage_enemy)

	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_body_entered)


func _on_damage_enemy(character: GameCharacter, damage: float, element_type: int = 0):
	if character == self:
		apply_damage(damage, self, element_type)


func apply_damage(damage: float, _source: Node2D, elem: int = 0, is_dot: bool = false):
	if fertilized and _source is Warden:
		return
	
	super(damage, _source, elem, is_dot)
	
	if curr_health <= 0.0 and not dead:
		if not fertilized and warden and warden.fertilized_farm_active:
			ally_lifetime = warden.get_meta("fertilizer_farm_lifetime", 10.0)
			stat_boost = warden.get_meta("fertilizer_farm_stat_boost", 1.0)
			_become_fertilized()
			return  
		
		dead = true
		animation_tree.active = false
		animation_player.play("death")

func _on_death(animation_name: StringName):
	if animation_name == "death":
		_die()

func _face_target() -> void:
	var direction_to_warden: float = target.global_position.x - global_position.x
	
	if direction_to_warden < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		
func _on_stat_modified(character_group: String, stat_name: String, value: float) -> void:
	if character_group != "enemies":
		return
	
	match stat_name:
		"movement_speed":
			global_slow_modifier *= value

func enter_frost_trail(slow_percent: float, duration: float = 5.0) -> void:	
	if is_instance_valid(frost_timer):
		frost_timer.queue_free()
	
	frost_trail_modifier = 1.0 - slow_percent
	
	
	frost_timer = Timer.new()
	frost_timer.wait_time = duration
	frost_timer.one_shot = true
	add_child(frost_timer)
	
	frost_timer.timeout.connect(
		func():
			frost_trail_modifier = 1.0
			if is_instance_valid(frost_timer):
				frost_timer.queue_free()
	)
	frost_timer.start()

func apply_burn(duration: float, _damage_multiplier: float = 1.0) -> void:
	is_burned = true
	
	if is_instance_valid(burn_timer):
		burn_timer.queue_free()
	
	burn_timer = Timer.new()
	burn_timer.wait_time = duration
	burn_timer.one_shot = true
	add_child(burn_timer)
	
	burn_timer.timeout.connect(
		func():
			is_burned = false
			if is_instance_valid(burn_timer):
				burn_timer.queue_free()
	)
	burn_timer.start()	

func apply_stun() -> void:	
	if is_instance_valid(stun_timer):
		stun_timer.queue_free()
	
	stunned = true
	
	stun_timer = Timer.new()
	stun_timer.wait_time = stun_time
	stun_timer.one_shot = true
	add_child(stun_timer)
	
	stun_timer.timeout.connect(
		func():
			stunned = false
			if is_instance_valid(stun_timer):
				stun_timer.queue_free()
	)
	stun_timer.start()

func _on_attack_area_body_entered(body: Node2D) -> void:
	
	if dead or stunned:
		return

	if fertilized:
		var target_fruit = body if body is Fruit else body.get_parent() if body.get_parent() is Fruit else null
		
		if target_fruit and target_fruit is Fruit and target_fruit != self and not target_fruit.dead:
			if attack_cooldown <= 0:
				is_attacking = true
				attack_cooldown = attack_rate
				
				target_fruit.apply_damage(attack_damage, self, element)
				
				var knockback_direction = (target_fruit.global_position - global_position).normalized()
				var knockback_strength = 200.0  # Adjust this value
				target_fruit.velocity = knockback_direction * knockback_strength
				
				
				await get_tree().create_timer(0.5).timeout
				is_attacking = false
			else:
				print("Attack on cooldown: ", attack_cooldown)
		return
	
	if body == peach_tree and peach_tree and peach_tree.is_dead:
		return

	if not fertilized and body == target and attack_cooldown <= 0:
		is_attacking = true
		attack_cooldown = attack_rate

		if target and target.has_method("apply_damage"):
			target.apply_damage(attack_damage, self, element)

		await get_tree().create_timer(0.5).timeout
		is_attacking = false
		
func _on_status_effect_applied(character_group: String, effect_name: String, parameters: Dictionary):
	if character_group != "game":
		return
	
	match effect_name:
		"fertilized_farm_active":
			ally_spawn_active = true
			ally_lifetime = parameters.get("ally_lifetime", 10.0)
			stat_boost = parameters.get("stat_boost", 1.0)
			
			var deactivate_timer = Timer.new()
			deactivate_timer.wait_time = parameters.get("duration", 5.0)
			deactivate_timer.one_shot = true
			add_child(deactivate_timer)
			
			deactivate_timer.timeout.connect(
				func():
					ally_spawn_active = false
					deactivate_timer.queue_free()
			)
			deactivate_timer.start()
	
	
func _become_fertilized():
	fertilized = true
	dead = false
	curr_health = max_health * 0.5
	
	attack_damage *= stat_boost
	speed *= stat_boost
	base_speed *= stat_boost
	
	if sprite:
		sprite.modulate = Color(0.7, 1.0, 0.3)
	
	remove_from_group("enemies")
	add_to_group("allies")
	
	if attack_area:
		attack_area.set_collision_mask_value(2, true)  
	
	var closest = _find_closest_enemy()
	if closest:
		target = closest

	
func _update_fertilized_target():
	if randf() > 0.02:
		return
	
	var closest_enemy = _find_closest_enemy()
	if closest_enemy:
		target = closest_enemy

func _find_closest_enemy() -> Fruit:
	if not is_inside_tree():
		return null
	
	var tree = get_tree()
	if not tree:
		return null
	
	var all_enemies = tree.get_nodes_in_group("enemies")
	var closest: Fruit = null
	var closest_distance := INF
	
	for enemy in all_enemies:
		if not enemy is Fruit or enemy == self or enemy.dead:
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = enemy
	
	return closest
