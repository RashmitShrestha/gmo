class_name Warden
extends GameCharacter

@export var dash_speed_curve: Curve
@export var knockback_speed_curve: Curve
@export var dash_invulnerability_duration: float
@export var invulnerability_duration: float
@export var command_manager_component: PlayerCommandManagerComponent
@export var input_component: PlayerInputComponent
@export var animation_manager_component: PlayerAnimationManagerComponent

@export var slice_radius = 300
@export var respawn_time: float
@export var respawn_point: Node2D

@onready var animation_tree: AnimationTree = $AnimationTree

var last_facing_direction := Vector2.RIGHT  
var _invulnerability_timer: Timer
var _blink_timer: Timer

var curr_command: Command
var idle_command: PlayerIdleCommand
var move_command: PlayerMoveCommand
var dash_command: PlayerDashCommand
var died_command: PlayerDiedCommand
var knockback_command: KnockbackCommand

var vel_vec := Vector2.ZERO
var curr_vel: int = 0
var is_slicing: bool = false

var attack_damage_multiplier: float = 1.0
var movement_speed_multiplier: float = 1.0
var max_health_multiplier: float = 1.0

var active_abilities: Dictionary = {
	"flame_trail": {"enabled": false, "params": {}},
	"frost_trail": {"enabled": false, "params": {}},
	"ferment_trail": {"enabled": false, "params": {}},
	"flame_flinger": {"enabled": false, "params": {}},
	"freeze_frame": {"enabled": false, "params": {}},
	"fertilized_farm": {"enabled": false, "params": {}}
}

var cd1 : float
var cd2 : float
var cd3 : float
var cd4 : float
var cd5 : float
var cd6 : float

var burn_crit_boost_active: bool = false
var burn_crit_chance_bonus: float = 0.0
var burn_crit_damage_bonus: float = 0.0

var freeze_on_hit_active: bool = false
var freeze_on_hit_chance: float = 0.0

var consecutive_hit_boost_active: bool = false
var consecutive_hits: int = 0
var last_hit_time: float = 0.0
var consecutive_hit_params: Dictionary = {}

var health_regen_active: bool = false
var health_regen_timer: Timer

var ally_stat_boost_active: bool = false
var ally_stat_boost_multiplier: float = 1.0

var recharging_shield_active: bool = false
var shield_up: bool = true
var shield_recharge_time: float = 10.0
var shield_recharge_timer: Timer

func _ready() -> void:
	animation_tree.active = true
	add_to_group("player")
	
	super._ready()
	
	animation_tree.active = true
	idle_command = PlayerIdleCommand.new()
	move_command = PlayerMoveCommand.new()
	dash_command = PlayerDashCommand.new(dash_speed_curve)
	died_command = PlayerDiedCommand.new(respawn_time, respawn_point.position)
	knockback_command = KnockbackCommand.new(knockback_speed_curve, self)
	
	#SignalBus.health_restored.connect(_on_health_restored)
	SignalBus.stat_modified.connect(_on_stat_modified)
	SignalBus.ability_toggled.connect(_on_ability_toggled)
	SignalBus.status_effect_applied.connect(_on_status_effect_applied)
	
	received_damage.connect(
		func(_damage: float, _source: Node2D):
			SignalBus.player_health_changed.emit(curr_health, max_health)

			if curr_health > 0.0:
				hurt_animation()
				make_invulnerable(invulnerability_duration)
			else:
				await warden_death_animation()

				var tree = get_tree().get_first_node_in_group("peach_tree")
				if tree and tree.is_dead:
					print("warden died and tree is dead")
					SignalBus.game_over.emit()
				else:
					print("warden died but tree is alive")
					SignalBus.player_died.emit()
	)
	queue_redraw()

func _input(event):
	input_component.update(event)

func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()

func _on_received_damage(character: GameCharacter, _damage: float) -> void:
	if character == self:
		hurt_animation()
		make_invulnerable(invulnerability_duration)

#func _on_health_restored(character: GameCharacter, amount: float) -> void:
	#if character == self:
		#print("warden heak")

# Handle when any character dies
#func _on_character_died(character: GameCharacter) -> void:
	#if character == self:
		#print("warden dead!")
	

func make_invulnerable(duration: float) -> void:
	if is_instance_valid(_invulnerability_timer):
		_invulnerability_timer.queue_free()
	_invulnerability_timer = null

	invulnerable = true
	
	_invulnerability_timer = Timer.new()
	_invulnerability_timer.one_shot = true
	add_child(_invulnerability_timer)
	
	_invulnerability_timer.timeout.connect(
		func():
			invulnerable = false
			if is_instance_valid(_invulnerability_timer):
				_invulnerability_timer.queue_free()
			_invulnerability_timer = null
	)
	_invulnerability_timer.start(duration)


func blink(blink_duration: float):
	if is_instance_valid(_blink_timer):
		_blink_timer.queue_free()
	_blink_timer = null
	
	_blink_timer = Timer.new()
	add_child(_blink_timer)
	
	_blink_timer.timeout.connect(
		func():
			sprite.visible = not sprite.visible
	)
	
	_blink_timer.start(0.06)
	
	get_tree().create_timer(blink_duration).timeout.connect(
		func():
			_blink_timer.stop()
	)


func hurt_animation():
	blink(invulnerability_duration)
	
	get_tree().create_timer(invulnerability_duration).timeout.connect(
		func():
			sprite.visible = true
	)
	
	sprite.self_modulate = Color(1.0, 0.117, 0.419, 0.5)
	await get_tree().create_timer(.5).timeout
	sprite.self_modulate = Color(1, 1, 1, 1)
	
	damaged = false


func warden_death_animation() -> void:
	animation_tree.active = false
	animation_player.play("death")
	
	await animation_player.animation_finished
	
	
func _on_stat_modified(character_group: String, stat_name: String, value: float) -> void:
	if character_group != "player":
		return
	
	match stat_name:
		"attack":
			attack_damage_multiplier *= value
				
		"movement_speed":
			movement_speed_multiplier *= value
			base_speed *= value
				
		"max_health":
			var old_max = max_health
			max_health_multiplier *= value
			max_health *= value
			curr_health += (max_health - old_max)
			SignalBus.player_health_changed.emit(curr_health, max_health)


func _on_ability_toggled(ability_id: String, enabled: bool, parameters: Dictionary) -> void:
	if active_abilities.has(ability_id):
		active_abilities[ability_id]["enabled"] = enabled
		active_abilities[ability_id]["params"] = parameters		


func _on_status_effect_applied(character_group: String, effect_name: String, parameters: Dictionary) -> void:
	if character_group != "player":
		return
	
	match effect_name:
		"burn_crit_boost":
			burn_crit_boost_active = true
			burn_crit_chance_bonus = parameters.get("crit_chance_bonus", 0.0)
			burn_crit_damage_bonus = parameters.get("crit_damage_bonus", 0.0)
			
		"freeze_on_hit":
			freeze_on_hit_active = true
			freeze_on_hit_chance = parameters.get("freeze_chance", 0.0)
			
		"consecutive_hit_boost":
			consecutive_hit_boost_active = true
			consecutive_hit_params = parameters
			
		"health_regen":
			health_regen_active = true
			_setup_health_regen(parameters.get("amount", 2), parameters.get("interval", 10.0))
			
		"ally_stat_boost":
			ally_stat_boost_active = true
			ally_stat_boost_multiplier = parameters.get("multiplier", 1.0)
			
		"recharging_shield":
			recharging_shield_active = true
			shield_recharge_time = parameters.get("recharge_time", 10.0)
			shield_up = true

func _setup_health_regen(amount: int, interval: float) -> void:
	if is_instance_valid(health_regen_timer):
		health_regen_timer.queue_free()
	
	health_regen_timer = Timer.new()
	health_regen_timer.wait_time = interval
	health_regen_timer.autostart = true
	add_child(health_regen_timer)
	
	health_regen_timer.timeout.connect(
		func():
			if curr_health < max_health:
				curr_health = min(curr_health + amount, max_health)
				SignalBus.health_restored.emit(self, amount)
				SignalBus.player_health_changed.emit(curr_health, max_health)
				spawn_heal_number(amount)
	)


func apply_damage(damage: float, source: Node2D, elem: int = 0, is_dot: bool = false) -> void:
	print(elem)
	if invulnerable:
		return
	
	if recharging_shield_active and shield_up and not is_dot:
		shield_up = false
		spawn_damage_number(damage, 4)
		_start_shield_recharge()
		make_invulnerable(0.5)
		return
	
	var final_damage = damage
	
	match elem:
		1:
			final_damage *= 2
	
	curr_health -= final_damage
	damaged = true
	
	if not is_dot:
		spawn_damage_number(final_damage, elem)

	if curr_health < 0.0:
		curr_health = 0.0
		

		
	received_damage.emit(final_damage, source)
	

func _start_shield_recharge() -> void:
	if is_instance_valid(shield_recharge_timer):
		shield_recharge_timer.queue_free()
	
	shield_recharge_timer = Timer.new()
	shield_recharge_timer.wait_time = shield_recharge_time
	shield_recharge_timer.one_shot = true
	add_child(shield_recharge_timer)
	
	shield_recharge_timer.timeout.connect(
		func():
			shield_up = true
			if is_instance_valid(shield_recharge_timer):
				shield_recharge_timer.queue_free()
	)
	shield_recharge_timer.start()

func calculate_slice_damage(target: GameCharacter) -> float:
	var damage = SliceDamage.calculate_damage(curr_vel, attack_damage_multiplier)
	
	if consecutive_hit_boost_active and consecutive_hits > 0:
		var atk_bonus = consecutive_hits * consecutive_hit_params.get("atk_per_hit", 0.01)
		damage *= (1.0 + atk_bonus)
	
	var target_is_burned = false
	if target is Fruit and target.is_burned:
		target_is_burned = true
	
	var crit_stats = get_crit_stats(target_is_burned)
	if randf() < crit_stats.chance:
		damage *= crit_stats.damage
	
	return damage

func get_crit_stats(enemy_is_burned: bool = false) -> Dictionary:
	var base_crit_chance = 0.05  
	var base_crit_damage = 1.5  
	
	var crit_chance = base_crit_chance
	var crit_dmg = base_crit_damage
	
	if burn_crit_boost_active and enemy_is_burned:
		crit_chance += burn_crit_chance_bonus
		crit_dmg += burn_crit_damage_bonus
	
	if consecutive_hit_boost_active and consecutive_hits > 0:
		crit_chance += consecutive_hits * consecutive_hit_params.get("crit_chance_per_hit", 0.01)
		crit_dmg += consecutive_hits * consecutive_hit_params.get("crit_dmg_per_hit", 0.01)
	
	return {"chance": crit_chance, "damage": crit_dmg}

func on_successful_hit(enemy: GameCharacter) -> void:
	
	if consecutive_hit_boost_active:
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_hit_time > consecutive_hit_params.get("reset_window", 0.5):
			consecutive_hits = 0
		consecutive_hits += 1
		last_hit_time = current_time
	
	if check_freeze_on_hit() and enemy is Fruit:
		enemy.apply_stun()

func check_freeze_on_hit() -> bool:
	if not freeze_on_hit_active:
		return false
	return randf() < freeze_on_hit_chance
