extends Node

var total_score: int = 0
var total_kills_score: int = 0
var total_wave_bonuses: int = 0
var total_health_bonuses: int = 0

var cached_player_health: float = 100.0
var cached_max_player_health: float = 100.0
var cached_base_health: float = 100.0
var cached_max_base_health: float = 100.0

var current_wave_kills: int = 0
var current_wave_kills_score: int = 0


func _ready() -> void:
	SignalBus.enemy_died.connect(_on_enemy_died)
	SignalBus.wave_started.connect(_on_wave_started)
	SignalBus.wave_completed.connect(_on_wave_completed)
	SignalBus.all_waves_completed.connect(_on_all_waves_completed)
	SignalBus.player_died.connect(_on_player_died)
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.base_health_changed.connect(_on_base_health_changed)

	print("ScoreManager: Initialized and ready to track scores")


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


func _on_wave_started(wave_number: int) -> void:
	current_wave_kills = 0
	current_wave_kills_score = 0
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

	var health_bonus = calculate_health_bonus(wave_bonus)
	total_health_bonuses += health_bonus
	total_score += health_bonus

	print("ScoreManager: Wave %d completed!" % wave_number)
	print("  - Kills this wave: %d (%d points)" % [current_wave_kills, current_wave_kills_score])
	print("  - Wave completion bonus: %d" % wave_bonus)
	print("  - Health bonus: %d" % health_bonus)
	print("  - Total score: %d" % total_score)


func _on_all_waves_completed() -> void:
	print("ScoreManager: All waves completed! Final score: %d" % total_score)


func _on_player_died() -> void:
	print("ScoreManager: Player died. Final score: %d" % total_score)


func _on_player_health_changed(new_health: float, max_health: float) -> void:
	cached_player_health = new_health
	cached_max_player_health = max_health


func _on_base_health_changed(new_health: float, max_health: float) -> void:
	cached_base_health = new_health
	cached_max_base_health = max_health


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


func get_score_breakdown() -> Dictionary:
	return {
		"total_score": total_score,
		"kills_score": total_kills_score,
		"wave_bonuses": total_wave_bonuses,
		"health_bonuses": total_health_bonuses
	}


func reset_score() -> void:
	total_score = 0
	total_kills_score = 0
	total_wave_bonuses = 0
	total_health_bonuses = 0
	current_wave_kills = 0
	current_wave_kills_score = 0
	print("ScoreManager: Score reset")
