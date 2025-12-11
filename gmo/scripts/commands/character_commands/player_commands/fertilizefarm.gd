#extends Area2D
#
#@export var duration := 10.0
#@export var activation_range := 800.0
#
#var is_active := false
#var player: Node2D
#var active_timer := 0.0
#var fertilized_enemies := []
#
#func _ready():
	#monitoring = false
	#monitorable = false
	#
	#player = get_parent()
	#
	#body_entered.connect(_on_body_entered)
	#body_exited.connect(_on_body_exited)
	#
	#SignalBus.enemy_died.connect(_on_enemy_died)
#
#func _process(delta):
	#if not is_active:
		#return
	#
	#active_timer -= delta
	#
	#if active_timer <= 0:
		#deactivate()
		#return
	#
	#global_position = player.global_position
	#
	## Update fertilized enemies' targets
	#_update_fertilized_targets()
#
#func toggle():
	#is_active = !is_active
	#
	#if is_active:
		#activate()
	#else:
		#deactivate()
#
#func activate():
	#is_active = true
	#active_timer = duration
	#
	#global_position = player.global_position
	#
	## Set up the detection area
	#var collision_shape = get_node_or_null("CollisionShape2D")
	#if collision_shape and collision_shape.shape is CircleShape2D:
		#collision_shape.shape.radius = activation_range
	#
	#monitoring = true
	#fertilized_enemies.clear()
	#
	## Fertilize all enemies currently in range
	#var enemies_in_range = get_tree().get_nodes_in_group("enemies")
	#for enemy in enemies_in_range:
		#if enemy is Fruit and is_instance_valid(enemy):
			#var distance = enemy.global_position.distance_to(player.global_position)
			#if distance <= activation_range:
				#_fertilize_enemy(enemy)
#
#func deactivate():
	#is_active = false
	#monitoring = false
	#
	## Revert all fertilized enemies back to normal
	#for enemy in fertilized_enemies:
		#if is_instance_valid(enemy):
			#_unfertilize_enemy(enemy)
	#
	#fertilized_enemies.clear()
#
#func _on_body_entered(body: Node2D):
	#if not is_active:
		#return
	#
	#if body is Fruit and not body in fertilized_enemies:
		#_fertilize_enemy(body)
#
#func _on_body_exited(body: Node2D):
	## Keep enemies fertilized even if they leave the area
	#pass
#
#func _on_enemy_died(_enemy_name: String, enemy: Node2D, _drop_type: int):
	#if not is_active:
		#return
	#
	## When an enemy dies, fertilize it if it's in range
	#if enemy is Fruit and enemy.global_position.distance_to(player.global_position) <= activation_range:
		#_fertilize_enemy(enemy)
#
#func _fertilize_enemy(enemy: Fruit):
	#if enemy.fertilized or enemy.dead:
		#return
	#
	#enemy.fertilized = true
	#fertilized_enemies.append(enemy)
	#
	## Find closest enemy as initial target
	#var closest_enemy = _find_closest_enemy(enemy)
	#if closest_enemy:
		#enemy.target = closest_enemy
	#
	## Visual feedback - could add a particle effect or color change
	#if enemy.sprite:
		#enemy.sprite.modulate = Color(0.7, 1.0, 0.3) # Ferment green color
#
#func _unfertilize_enemy(enemy: Fruit):
	#if not is_instance_valid(enemy) or enemy.dead:
		#return
	#
	#enemy.fertilized = false
	#
	## Reset target to original behavior
	#if enemy.peach_tree and not enemy.peach_tree.is_dead:
		#if randf() < enemy.target_warden_chance:
			#enemy.target = enemy.warden
		#else:
			#enemy.target = enemy.peach_tree
	#else:
		#enemy.target = enemy.warden
	#
	## Reset visual
	#if enemy.sprite:
		#enemy.sprite.modulate = Color(1.0, 1.0, 1.0)
#
#func _update_fertilized_targets():
	#for enemy in fertilized_enemies:
		#if not is_instance_valid(enemy) or enemy.dead:
			#continue
		#
		## Periodically update target to closest enemy
		#if randf() < 0.1: # 10% chance per frame to retarget
			#var closest = _find_closest_enemy(enemy)
			#if closest:
				#enemy.target = closest
#
#func _find_closest_enemy(source_enemy: Fruit) -> Fruit:
	#var all_enemies = get_tree().get_nodes_in_group("enemies")
	#var closest: Fruit = null
	#var closest_distance := INF
	#
	#for enemy in all_enemies:
		#if not enemy is Fruit:
			#continue
		#
		#if enemy == source_enemy or enemy.dead:
			#continue
		#
		## Fertilized enemies can attack both fertilized and non-fertilized
		#var distance = source_enemy.global_position.distance_to(enemy.global_position)
		#
		#if distance < closest_distance:
			#closest_distance = distance
			#closest = enemy
	#
	#return closest
