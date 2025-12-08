extends Node

# Freeze Frame Ability
# Activation: "special_5" (E)
# Effect: Freezes all enemies, turns them frozen color, and stops projectiles from firing
# Nitrogen Nirvana: 2x speed + unlimited slice range

var player: CharacterBody2D

# ability states
var unlocked: bool = false
var duration: float = 4.0
var speed_boost: float = 1.0  # for Nitrogen Nirvana: 2.0
var unlimited_range: bool = false

# cooldown
var cooldown: float = 30.0
var can_use: bool = true
var active: bool = false

# tracking
var frozen_enemies: Array = []
var frozen_projectiles: Array = []

# original stat values to reset to after Nitrogen Nirvana
var original_speed: float = 0.0
var original_base_speed: float = 0.0
var original_slice_radius: float = 0.0

var unlimited_slice_radius: float = 10000.0

var frost_color: Color = Color(0.3, 0.6, 1.0)


func _ready() -> void:
	player = get_parent()
	SignalBus.ability_toggled.connect(_on_ability_toggled)

func _on_ability_toggled(ability_id: String, enabled: bool, parameters: Dictionary) -> void:
	if ability_id != "freeze_frame":
		return
	
	unlocked = enabled
	
	if parameters.has("duration"):
		duration = parameters.duration
	if parameters.has("speed_multiplier"):
		speed_boost = parameters.speed_multiplier
	if parameters.has("unlimited_range"):
		unlimited_range = parameters.unlimited_range
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("special_5"):
		if not unlocked:
			return
		
		if not can_use:
			return
		
		if active:
			return
		
		_activate_freeze_frame()


func _activate_freeze_frame() -> void:
	
	active = true
	can_use = false
	frozen_enemies.clear()
	frozen_projectiles.clear()
	
	# freeze enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			_freeze_enemy(enemy)
	
	
	# freeze existing projectiles
	var projectiles = get_tree().get_nodes_in_group("projectiles")
	for projectile in projectiles:
		if is_instance_valid(projectile):
			_freeze_projectile(projectile)
	
	if speed_boost > 1.0:
		_apply_player_speed_boost()
	
	if unlimited_range:
		_apply_unlimited_range()
	
	await get_tree().create_timer(duration).timeout
	_deactivate_freeze_frame()


func _apply_player_speed_boost() -> void:
	if not player:
		return
		
	if "speed" in player:
		original_speed = player.speed
		player.speed *= speed_boost
	
	if "base_speed" in player:
		original_base_speed = player.base_speed
		player.base_speed *= speed_boost


func _remove_player_speed_boost() -> void:
	if not player:
		return
	
	if original_speed > 0.0 and "speed" in player:
		player.speed = original_speed
	
	if original_base_speed > 0.0 and "base_speed" in player:
		player.base_speed = original_base_speed
		

	
	original_speed = 0.0
	original_base_speed = 0.0


func _apply_unlimited_range() -> void:
	if not player:
		return
	
	if "slice_radius" in player:
		original_slice_radius = player.slice_radius
		player.slice_radius = unlimited_slice_radius

func _remove_unlimited_range() -> void:
	if original_slice_radius <= 0.0 or not player:
		return
	
	if "slice_radius" in player:
		player.slice_radius = original_slice_radius
	
	original_slice_radius = 0.0


func _freeze_enemy(enemy: Node) -> void:
	if not is_instance_valid(enemy):
		return
	
	enemy.set_meta("ff_process", enemy.is_processing())
	enemy.set_meta("ff_physics_process", enemy.is_physics_processing())
	
	
	# Store and zero velocity
	if "velocity" in enemy:
		enemy.set_meta("ff_velocity", enemy.velocity)
		enemy.velocity = Vector2.ZERO
	
	# Disable attacking
	if "can_attack" in enemy:
		enemy.set_meta("ff_can_attack", enemy.can_attack)
		enemy.can_attack = false
	
	enemy.set_process(false)
	enemy.set_physics_process(false)
	
	# applies frozen color to all sprites
	_apply_frost_color_recursive(enemy, enemy)
	
	# pause animations
	var anim_tree = enemy.get_node_or_null("AnimationTree")
	if anim_tree:
		enemy.set_meta("ff_anim_active", anim_tree.active)
		anim_tree.active = false
	
	var anim_player = enemy.get_node_or_null("AnimationPlayer")
	if anim_player and anim_player.is_playing():
		enemy.set_meta("ff_anim_playing", true)
		anim_player.pause()
	
	# pause timers
	for child in enemy.get_children():
		if child is Timer and child.time_left > 0:
			child.paused = true
			enemy.set_meta("ff_timer_" + child.name, true)
	
	frozen_enemies.append(enemy)


func _apply_frost_color_recursive(root: Node, node: Node) -> void:
	if node is Sprite2D:
		var sprite = node as Sprite2D
		root.set_meta("ff_color_" + str(sprite.get_instance_id()), sprite.modulate)
		sprite.modulate = frost_color
	elif node is AnimatedSprite2D:
		var sprite = node as AnimatedSprite2D
		root.set_meta("ff_anim_color_" + str(sprite.get_instance_id()), sprite.modulate)
		sprite.modulate = frost_color
	
	for child in node.get_children():
		_apply_frost_color_recursive(root, child)


func _restore_color_recursive(root: Node, node: Node) -> void:
	if node is Sprite2D:
		var sprite = node as Sprite2D
		var key = "ff_color_" + str(sprite.get_instance_id())
		if root.has_meta(key):
			sprite.modulate = root.get_meta(key)
			root.remove_meta(key)
	elif node is AnimatedSprite2D:
		var sprite = node as AnimatedSprite2D
		var key = "ff_anim_color_" + str(sprite.get_instance_id())
		if root.has_meta(key):
			sprite.modulate = root.get_meta(key)
			root.remove_meta(key)
	
	for child in node.get_children():
		_restore_color_recursive(root, child)


func _freeze_projectile(projectile: Node) -> void:
	if not is_instance_valid(projectile):
		return
	
	projectile.set_meta("ff_process", projectile.is_processing())
	projectile.set_meta("ff_physics_process", projectile.is_physics_processing())
	
	if "velocity" in projectile:
		projectile.set_meta("ff_velocity", projectile.velocity)
		projectile.velocity = Vector2.ZERO
	
	if "speed" in projectile:
		projectile.set_meta("ff_speed", projectile.speed)
		projectile.speed = 0.0
	
	projectile.set_process(false)
	projectile.set_physics_process(false)
	
	_apply_frost_color_recursive(projectile, projectile)
	
	frozen_projectiles.append(projectile)


func _unfreeze_enemy(enemy: Node) -> void:
	if not is_instance_valid(enemy):
		return
	
	# restores enemy movement
	if enemy.has_meta("ff_process"):
		enemy.set_process(enemy.get_meta("ff_process"))
		enemy.remove_meta("ff_process")
	else:
		enemy.set_process(true)
	
	if enemy.has_meta("ff_physics_process"):
		enemy.set_physics_process(enemy.get_meta("ff_physics_process"))
		enemy.remove_meta("ff_physics_process")
	else:
		enemy.set_physics_process(true)
	
	# restores speed
	if enemy.has_meta("ff_speed"):
		enemy.speed = enemy.get_meta("ff_speed")
		enemy.remove_meta("ff_speed")
	
	# restores base_speed
	if enemy.has_meta("ff_base_speed"):
		enemy.base_speed = enemy.get_meta("ff_base_speed")
		enemy.remove_meta("ff_base_speed")
	
	# restores fruit attacks
	if enemy.has_meta("ff_can_attack"):
		enemy.can_attack = enemy.get_meta("ff_can_attack")
		enemy.remove_meta("ff_can_attack")
	
	# Clear velocity meta
	if enemy.has_meta("ff_velocity"):
		enemy.remove_meta("ff_velocity")
	
	# Restore colors recursively
	_restore_color_recursive(enemy, enemy)
	
	# Restore animations
	var anim_tree = enemy.get_node_or_null("AnimationTree")
	if anim_tree and enemy.has_meta("ff_anim_active"):
		anim_tree.active = enemy.get_meta("ff_anim_active")
		enemy.remove_meta("ff_anim_active")
	
	var anim_player = enemy.get_node_or_null("AnimationPlayer")
	if anim_player and enemy.has_meta("ff_anim_playing"):
		anim_player.play()
		enemy.remove_meta("ff_anim_playing")
	
	# Unpause timers
	for child in enemy.get_children():
		if child is Timer:
			var key = "ff_timer_" + child.name
			if enemy.has_meta(key):
				child.paused = false
				enemy.remove_meta(key)


func _unfreeze_projectile(projectile: Node) -> void:
	if not is_instance_valid(projectile):
		return
	
	if projectile.has_meta("ff_process"):
		projectile.set_process(projectile.get_meta("ff_process"))
		projectile.remove_meta("ff_process")
	else:
		projectile.set_process(true)
	
	if projectile.has_meta("ff_physics_process"):
		projectile.set_physics_process(projectile.get_meta("ff_physics_process"))
		projectile.remove_meta("ff_physics_process")
	else:
		projectile.set_physics_process(true)
	
	if projectile.has_meta("ff_velocity"):
		projectile.velocity = projectile.get_meta("ff_velocity")
		projectile.remove_meta("ff_velocity")
	
	if projectile.has_meta("ff_speed"):
		projectile.speed = projectile.get_meta("ff_speed")
		projectile.remove_meta("ff_speed")
	
	_restore_color_recursive(projectile, projectile)


func _deactivate_freeze_frame() -> void:
	
	active = false
	
	# Unfreeze all enemies
	for enemy in frozen_enemies:
		if is_instance_valid(enemy):
			_unfreeze_enemy(enemy)
	frozen_enemies.clear()
	
	# Unfreeze all projectiles
	for projectile in frozen_projectiles:
		if is_instance_valid(projectile):
			_unfreeze_projectile(projectile)
	frozen_projectiles.clear()
	
	# remove Nitrogen Nirvana bonuses
	if speed_boost > 1.0:
		_remove_player_speed_boost()
	
	if unlimited_range:
		_remove_unlimited_range()
	
	# Start cooldown
	await get_tree().create_timer(cooldown).timeout
	can_use = true
