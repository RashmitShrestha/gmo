extends Node

var total_score: int = 0
var total_kills_score: int = 0
var total_wave_bonuses: int = 0
var total_health_bonuses: int = 0
var death_count: int = 0
var death_penalty: int = 0
var current_wave: int = 0

var cached_player_health: float = 100.0
var cached_max_player_health: float = 100.0
var cached_base_health: float = 100.0
var cached_max_base_health: float = 100.0

var current_wave_kills: int = 0
var current_wave_kills_score: int = 0

var gameplay_time: float = 0.0
var is_timer_running: bool = false

# XP tracking
var total_xp: int = 0
var total_kills_xp: int = 0
var total_wave_xp: int = 0
var total_health_bonus_xp: int = 0
var total_damage_bonus_xp: int = 0
var total_speed_bonus_xp: int = 0

# Wave-specific damage tracking
var wave_start_player_health: float = 100.0
var wave_start_base_health: float = 100.0
var min_player_health_this_wave: float = 100.0
var min_base_health_this_wave: float = 100.0
var wave_start_time: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	SignalBus.enemy_died.connect(_on_enemy_died)
	SignalBus.wave_started.connect(_on_wave_started)
	SignalBus.wave_completed.connect(_on_wave_completed)
	SignalBus.all_waves_completed.connect(_on_all_waves_completed)
	SignalBus.player_died.connect(_on_player_died)
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.base_health_changed.connect(_on_base_health_changed)

	print("ScoreManager: Initialized and ready to track scores")


func _process(delta: float) -> void:
	if is_timer_running:
		gameplay_time += delta


func _on_enemy_died(enemy_type: String, enemy_node: Node2D, drop_type: int) -> void:
	if not is_instance_valid(enemy_node):
		return

	var modifier = enemy_node.get_meta("modifier", 0)
	if modifier != 0:
		return

	var stats = enemy_node.get_meta("enemy_stats", null)
	if stats and stats.score_value > 0:
		total_kills_score += stats.score_value
		total_score += stats.score_value
		current_wave_kills += 1
		current_wave_kills_score += stats.score_value

		print("ScoreManager: +%d points for killing %s (total: %d)" % [stats.score_value, enemy_type, total_score])

		_award_xp(stats.score_value, "kill")


func _on_wave_started(wave_number: int) -> void:
	current_wave = wave_number
	current_wave_kills = 0
	current_wave_kills_score = 0

	wave_start_player_health = cached_player_health
	wave_start_base_health = cached_base_health
	min_player_health_this_wave = cached_player_health
	min_base_health_this_wave = cached_base_health
	wave_start_time = gameplay_time

	if wave_number == 1 and not is_timer_running:
		is_timer_running = true
		gameplay_time = 0.0
		wave_start_time = 0.0
		print("ScoreManager: Timer started")

	print("ScoreManager: Wave %d started" % wave_number)


func _on_wave_completed(wave_number: int) -> void:
	var wave_manager = get_node_or_null("/root/GameArea/WaveManager")
	if not wave_manager:
		print("ScoreManager: Warning - Could not find WaveManager")
		return

	var wave_data = wave_manager.current_wave_data
	if not wave_data:
		print("ScoreManager: Warning - No current wave data")
		return

	var wave_bonus = wave_data.wave_completion_bonus
	total_wave_bonuses += wave_bonus
	total_score += wave_bonus

	_award_xp(wave_bonus, "wave")

	var damage_bonus = calculate_damage_avoidance_bonus(wave_bonus)
	if damage_bonus > 0:
		_award_xp(damage_bonus, "damage_bonus")

	var speed_bonus = calculate_speed_bonus(wave_bonus, wave_data)
	if speed_bonus > 0:
		_award_xp(speed_bonus, "speed_bonus")

	print("ScoreManager: Wave %d completed!" % wave_number)
	print("  - Kills this wave: %d (%d points)" % [current_wave_kills, current_wave_kills_score])
	print("  - Wave completion bonus: %d" % wave_bonus)
	print("  - Damage avoidance bonus: %d XP" % damage_bonus)
	print("  - Speed bonus: %d XP" % speed_bonus)
	print("  - Total score: %d" % total_score)
	print("  - Total XP: %d" % total_xp)


func _on_all_waves_completed() -> void:
	is_timer_running = false
	print("ScoreManager: All waves completed! Final score: %d, Time: %s" % [total_score, _format_time(gameplay_time)])


func _on_player_died() -> void:
	death_count += 1
	var penalty = 100
	death_penalty += penalty
	total_score -= penalty

	print("ScoreManager: Player died (death #%d, -%d points). Score: %d, Time: %s" % [death_count, penalty, total_score, _format_time(gameplay_time)])


func _on_player_health_changed(new_health: float, max_health: float) -> void:
	cached_player_health = new_health
	cached_max_player_health = max_health

	if new_health < min_player_health_this_wave:
		min_player_health_this_wave = new_health


func _on_base_health_changed(new_health: float, max_health: float) -> void:
	cached_base_health = new_health
	cached_max_base_health = max_health

	if new_health < min_base_health_this_wave:
		min_base_health_this_wave = new_health


func calculate_health_bonus(wave_completion_bonus: int) -> int:

	var player_pct = 0.0
	var base_pct = 0.0

	if cached_max_player_health > 0:
		player_pct = cached_player_health / cached_max_player_health

	if cached_max_base_health > 0:
		base_pct = cached_base_health / cached_max_base_health

	var avg_pct = (player_pct + base_pct) / 2.0

	var bonus = int(avg_pct * wave_completion_bonus * 0.5)

	return bonus


func _format_time(seconds: float) -> String:
	var total_seconds = int(seconds)
	var minutes = total_seconds / 60
	var secs = total_seconds % 60

	if minutes >= 60:
		var hours = minutes / 60
		var mins = minutes % 60
		return "%d:%02d:%02d" % [hours, mins, secs]
	else:
		return "%d:%02d" % [minutes, secs]


func get_formatted_time() -> String:
	return _format_time(gameplay_time)


func get_score_breakdown() -> Dictionary:
	return {
		"total_score": total_score,
		"kills_score": total_kills_score,
		"wave_bonuses": total_wave_bonuses,
		"health_bonuses": total_health_bonuses,
		"death_count": death_count,
		"death_penalty": death_penalty,
		"current_wave": current_wave,
		"gameplay_time": gameplay_time,
		"formatted_time": get_formatted_time()
	}


func reset_score() -> void:
	total_score = 0
	total_kills_score = 0
	total_wave_bonuses = 0
	total_health_bonuses = 0
	current_wave_kills = 0
	current_wave_kills_score = 0
	gameplay_time = 0.0
	is_timer_running = false
	print("ScoreManager: Score reset")


func _award_xp(amount: int, source: String) -> void:
	total_xp += amount

	match source:
		"kill":
			total_kills_xp += amount
		"wave":
			total_wave_xp += amount
		"health":
			total_health_bonus_xp += amount
		"damage_bonus":
			total_damage_bonus_xp += amount
		"speed_bonus":
			total_speed_bonus_xp += amount

	var skill_tree = get_tree().get_first_node_in_group("skill_tree_menu")
	if skill_tree and skill_tree.has_method("add_xp"):
		skill_tree.add_xp(amount)

	print("ScoreManager: +%d XP from %s (total: %d)" % [amount, source, total_xp])


func calculate_damage_avoidance_bonus(wave_completion_bonus: int) -> int:
	if cached_max_player_health <= 0 or cached_max_base_health <= 0:
		return 0

	var player_damage_pct = (wave_start_player_health - min_player_health_this_wave) / cached_max_player_health
	var base_damage_pct = (wave_start_base_health - min_base_health_this_wave) / cached_max_base_health
	var avg_damage_pct = (player_damage_pct + base_damage_pct) / 2.0

	var damage_avoidance_multiplier = clamp(1.0 - avg_damage_pct, 0.0, 1.0)
	var damage_bonus_xp = int(wave_completion_bonus * damage_avoidance_multiplier)

	return damage_bonus_xp


func calculate_speed_bonus(wave_completion_bonus: int, wave_data) -> int:
	if not wave_data or not wave_data.has_method("get_estimated_duration"):
		return 0

	var estimated_duration = wave_data.get_estimated_duration()
	if estimated_duration <= 0:
		return 0

	var actual_duration = gameplay_time - wave_start_time
	var time_saved = estimated_duration - actual_duration

	var speed_multiplier = clamp(time_saved / estimated_duration, 0.0, 0.5)
	var speed_bonus_xp = int(wave_completion_bonus * speed_multiplier)

	return speed_bonus_xp


func get_xp_breakdown() -> Dictionary:
	return {
		"total_xp": total_xp,
		"kills_xp": total_kills_xp,
		"wave_xp": total_wave_xp,
		"health_bonus_xp": total_health_bonus_xp,
		"damage_bonus_xp": total_damage_bonus_xp,
		"speed_bonus_xp": total_speed_bonus_xp
	}
