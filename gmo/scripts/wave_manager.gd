# wavemanger that does enemy spawning
#auto loads the wave from resources/waves/, spawns the enemies, and completion via SignalBus
class_name WaveManager extends Node

enum WaveState {
	IDLE,
	SPAWNING,
	ACTIVE
}

@export var waves_folder: String = "res://resources/waves/"
@export var spawn_radius: float = 800.0
@export var auto_start_first_wave: bool = false
@export var debug_mode: bool = true

var current_wave_number: int = 0
var current_wave_data: WaveData = null
var wave_state: WaveState = WaveState.IDLE
var wave_resources: Array[WaveData] = []

var enemies_alive_count: int = 0
var spawned_enemies: Array[WeakRef] = []
var spawn_points: Array[Marker2D] = []

var _current_group_index: int = 0
var _enemies_spawned_in_group: int = 0
var _current_spawn_positions: Array[Vector2] = []
var _current_spawn_group: EnemyGroup = null
var spawn_timer: Timer
var group_delay_timer: Timer

func _ready():
	_setup_timers()
	_load_waves()
	_discover_spawn_points()
	SignalBus.enemy_died.connect(_on_enemy_died)

	if auto_start_first_wave:
		start_next_wave()

	print("wavemanager: ready! loaded %d waves, found %d spawn points" % [wave_resources.size(), spawn_points.size()])

func _setup_timers():
	spawn_timer = Timer.new()
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

	group_delay_timer = Timer.new()
	group_delay_timer.one_shot = true
	group_delay_timer.timeout.connect(_on_group_delay_timeout)
	add_child(group_delay_timer)

func _load_waves() -> void:
	wave_resources.clear()
	for i in range(1, 11):
		var wave_path = waves_folder + "wave_%02d.tres" % i
		if ResourceLoader.exists(wave_path):
			var wave = load(wave_path) as WaveData
			if wave:
				wave_resources.append(wave)
				print("wavemanager: loaded wave %d - %s" % [i, wave.wave_name])
		else:
			push_warning("WaveManager: Wave file not found: " + wave_path)

	print("wavemanager: loaded %d waves total" % wave_resources.size())

func _discover_spawn_points() -> void:
	var spawn_container = get_tree().get_first_node_in_group("spawn_points")
	if spawn_container:
		for child in spawn_container.get_children():
			if child is Marker2D:
				spawn_points.append(child)

	if spawn_points.is_empty():
		print("wavemanager: no spawn markers found, will use calculated positions")
	else:
		print("wavemanager: found %d spawn markers" % spawn_points.size())


#need to be called from ui/gamemanger
#call this from start wave
func start_next_wave() -> void:
	if current_wave_number >= wave_resources.size():
		print("wavemanager: all waves completed!")
		SignalBus.all_waves_completed.emit()
		return

	current_wave_number += 1
	start_wave(wave_resources[current_wave_number - 1])

func start_wave(wave_data: WaveData) -> void:
	if wave_state != WaveState.IDLE:
		push_warning("WaveManager: Cannot start wave, currently in state: " + WaveState.keys()[wave_state])
		return

	current_wave_data = wave_data
	wave_state = WaveState.SPAWNING
	_current_group_index = 0

	print("wavemanager: starting wave %d - %s" % [wave_data.wave_number, wave_data.wave_name])
	SignalBus.wave_started.emit(wave_data.wave_number)

	if wave_data.enemy_groups.size() > 0:
		_spawn_group(wave_data.enemy_groups[0])
	else:
		push_error("WaveManager: Wave has no enemy groups!")
		_complete_wave()

func _complete_wave() -> void:
	if wave_state == WaveState.IDLE:
		return

	wave_state = WaveState.IDLE

	if current_wave_data.spawn_boss_at_end and current_wave_data.boss_stats:
		print("wavemanager: spawning boss after wave completion")
		_spawn_boss()
	else:
		print("wavemanager: wave %d completed!" % current_wave_number)
		SignalBus.wave_completed.emit(current_wave_number)
		
		await get_tree().create_timer(5.0).timeout
		start_next_wave()

func _spawn_boss():
	var boss_pos = Vector2.ZERO
	print("wavemanager: spawning boss: %s" % current_wave_data.boss_stats.enemy_name)
	_spawn_enemy(current_wave_data.boss_stats, boss_pos, EnemyStats.EnemyModifier.NONE)

# group spawning

func _spawn_group(group: EnemyGroup) -> void:
	if not group or not group.enemy_stats:
		push_error("WaveManager: Invalid enemy group!")
		_move_to_next_group()
		return

	print("wavemanager: spawning group '%s' - %d x %s" % [group.group_name, group.count, group.enemy_stats.enemy_name])

	var positions = _calculate_spawn_positions(group.spawn_pattern, group.count)
	_enemies_spawned_in_group = 0
	_current_spawn_positions = positions
	_current_spawn_group = group


	if group.spawn_delay > 0 and _current_group_index == 0:
		await get_tree().create_timer(group.spawn_delay).timeout

	spawn_timer.start(group.spawn_interval)

func _on_spawn_timer_timeout():
	if _enemies_spawned_in_group >= _current_spawn_group.count:
		spawn_timer.stop()

		_move_to_next_group()
		return

	var pos = _current_spawn_positions[_enemies_spawned_in_group]
	var modifier = _get_enemy_modifier(_current_spawn_group)
	_spawn_enemy(_current_spawn_group.enemy_stats, pos, modifier)
	_enemies_spawned_in_group += 1

func _move_to_next_group():
	_current_group_index += 1

	if _current_group_index >= current_wave_data.enemy_groups.size():
		wave_state = WaveState.ACTIVE
		print("wavemanager: all groups spawned for wave %d" % current_wave_number)
		return

	if current_wave_data.spawn_delay_between_groups > 0:
		group_delay_timer.start(current_wave_data.spawn_delay_between_groups)
	else:
		_on_group_delay_timeout()

func _on_group_delay_timeout():
	_spawn_group(current_wave_data.enemy_groups[_current_group_index])

# spawning da eneemy
func _spawn_enemy(stats: EnemyStats, pos: Vector2, modifier: EnemyStats.EnemyModifier) -> Node2D:
	if stats.scene_path.is_empty():
		push_error("wavemanager: no scene_path for enemy: " + stats.enemy_name)
		return null

	if not ResourceLoader.exists(stats.scene_path):
		push_error("wavemanager:scene not found: " + stats.scene_path)
		return null

	var scene = load(stats.scene_path) as PackedScene
	if not scene:
		push_error("wavemanager:failed to load scene: " + stats.scene_path)
		return null

	var enemy = scene.instantiate()
	enemy.position = pos

	_apply_modifier_to_enemy(enemy, modifier)

	enemy.set_meta("enemy_stats", stats)
	enemy.set_meta("modifier", modifier)
	enemy.set_meta("enemy_name", stats.enemy_name)

	var warden_node = get_parent().get_node_or_null("Warden")
	if warden_node and "warden" in enemy:
		enemy.warden = warden_node

	enemies_alive_count += 1
	spawned_enemies.append(weakref(enemy))
	get_parent().add_child(enemy)

	SignalBus.enemy_spawned.emit(stats.enemy_name, enemy)

	if debug_mode:
		print("wavemanager: spawned %s at %v (modifier: %s)" % [stats.enemy_name, pos, EnemyStats.EnemyModifier.keys()[modifier]])

	return enemy

# ========== Spawn Patterns ==========

func _calculate_spawn_positions(pattern: EnemyGroup.SpawnPattern, count: int) -> Array[Vector2]:
	var positions: Array[Vector2] = []

	match pattern:
		EnemyGroup.SpawnPattern.RANDOM_PERIMETER:
			for i in count:
				positions.append(_get_random_perimeter_position())

		EnemyGroup.SpawnPattern.SPREAD:
			var angle_step = TAU / count
			for i in count:
				var angle = i * angle_step
				var pos = Vector2(cos(angle), sin(angle)) * spawn_radius
				positions.append(pos)

		EnemyGroup.SpawnPattern.CLUSTER:
			var base_pos = _get_random_perimeter_position()
			for i in count:
				var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
				positions.append(base_pos + offset)

		EnemyGroup.SpawnPattern.LINE:
			var start = _get_random_perimeter_position()
			var direction = Vector2.RIGHT.rotated(randf() * TAU)
			for i in count:
				positions.append(start + direction * i * 60)

		EnemyGroup.SpawnPattern.CIRCLE:
			var center = Vector2.ZERO
			var radius = 300.0
			var angle_step = TAU / count
			for i in count:
				var angle = i * angle_step
				positions.append(center + Vector2(cos(angle), sin(angle)) * radius)

	return positions

func _get_random_perimeter_position() -> Vector2:
	if not spawn_points.is_empty():
		return spawn_points.pick_random().global_position

	var angle = randf() * TAU
	return Vector2(cos(angle), sin(angle)) * spawn_radius
#for modifing enemies
func _get_enemy_modifier(group: EnemyGroup) -> EnemyStats.EnemyModifier:
	if group.force_modifier != EnemyStats.EnemyModifier.NONE:
		return group.force_modifier

	if group.modifier_chance > 0 and randf() < group.modifier_chance:
		return current_wave_data.get_random_modifier()

	return current_wave_data.get_random_modifier()

func _apply_modifier_to_enemy(enemy: Node2D, modifier: EnemyStats.EnemyModifier):
	if modifier == EnemyStats.EnemyModifier.NONE:
		return

	var tint_color = Color.WHITE
	match modifier:
		EnemyStats.EnemyModifier.GRILLED:
			tint_color = Color(1.3, 0.8, 0.6)

		EnemyStats.EnemyModifier.FROZEN:
			tint_color = Color(0.7, 0.9, 1.2)
		EnemyStats.EnemyModifier.ROTTEN:
			tint_color = Color(0.7, 0.8, 0.5)

	if enemy.has_node("Sprite2D"):
		enemy.get_node("Sprite2D").modulate = tint_color

	elif enemy.has_node("AnimatedSprite2D"):
		enemy.get_node("AnimatedSprite2D").modulate = tint_color


# needs to be connected to enemy dying, SignalBus.enemy_died.emit(enemy_name, self, drop_type)

func _on_enemy_died(enemy_type: String, enemy_node: Node2D, drop_type: int):
	enemies_alive_count -= 1

	if debug_mode:
		print("wavemanager: enemy died - %s (%d enemies remaining)" % [enemy_type, enemies_alive_count])

	spawned_enemies = spawned_enemies.filter(func(wr): return wr.get_ref() != null)

	if enemies_alive_count <= 0 and not _is_still_spawning():
		_complete_wave()

func _is_still_spawning() -> bool:
	return wave_state == WaveState.SPAWNING or spawn_timer.time_left > 0

# some debug stuff
func _input(event):
	if not debug_mode:
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_N:
				print("debug: starting next wave")
				start_next_wave()
			KEY_K:
				print("debug: clearing all enemies")
				clear_all_enemies()
				_complete_wave()
			KEY_R:
				print("debug: resetting wavemanager")
				reset()
			KEY_P:
				print("debug: wave progress:")
				print(get_wave_progress())
			# Number keys to jump to specific waves
			KEY_1:
				print("debug: jumping to wave 1")
				reset()
				start_next_wave()
			KEY_2:
				print("debug: jumping to wave 2")
				skip_to_wave(2)
			KEY_3:
				print("debug: jumping to wave 3")
				skip_to_wave(3)
			KEY_4:
				print("debug: jumping to wave 4")
				skip_to_wave(4)
			KEY_5:
				print("debug: jumping to wave 5")
				skip_to_wave(5)
			KEY_6:
				print("debug: jumping to wave 6")
				skip_to_wave(6)
			KEY_7:
				print("debug: jumping to wave 7")
				skip_to_wave(7)
			KEY_8:
				print("debug: jumping to wave 8")
				skip_to_wave(8)
			KEY_9:
				print("debug: jumping to wave 9")
				skip_to_wave(9)
			KEY_0:
				print("debug: jumping to wave 10")
				skip_to_wave(10)


func skip_to_wave(wave_num: int) -> void:
	current_wave_number = wave_num - 1
	start_next_wave()

func clear_all_enemies() -> void:
	for weak_ref in spawned_enemies:
		var enemy = weak_ref.get_ref()
		if enemy:
			SignalBus.enemy_died.emit("Debug", enemy, 0)
			enemy.queue_free()
	enemies_alive_count = 0
	spawned_enemies.clear()

func reset():
	current_wave_number = 0
	current_wave_data = null
	wave_state = WaveState.IDLE
	clear_all_enemies()
	spawn_timer.stop()
	group_delay_timer.stop()
	print("wavemanager: reset complete")


func get_wave_progress() -> Dictionary:
	return {
		"wave": current_wave_number,
		"state": WaveState.keys()[wave_state],
		"enemies_alive": enemies_alive_count,
		"group_index": _current_group_index,
		"total_waves": wave_resources.size()
	}
