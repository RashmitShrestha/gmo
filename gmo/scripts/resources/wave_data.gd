# resource for defining wave spawning logic. create .tres files instead of writing code
# HOW TO USE:
#   1. Right-click resources/waves/ → New Resource → WaveData → save as wave_XX.tres
#   2. Add enemy groups to the array and configure each group
#   3. Modifier weights work like: grilled:2 frozen:1 rotten:1 = 50% grilled, 25% each for others
# See wave_01.tres, wave_05.tres, wave_10.tres for examples
class_name WaveData extends Resource

@export var wave_number: int = 1
@export var wave_name: String = "Wave"
@export_multiline var description: String = ""

@export_group("Enemy Spawning")
@export var enemy_groups: Array[EnemyGroup] = []
@export var spawn_delay_between_groups: float = 2.0

@export_group("Difficulty & Modifiers")
@export_range(0.0, 1.0) var modifier_spawn_chance: float = 0.0
# weights determine modifier distribution: higher weight = more likely
@export var grilled_weight: float = 1.0
@export var frozen_weight: float = 1.0
@export var rotten_weight: float = 1.0

@export_group("Rewards")
@export var wave_completion_bonus: int = 100

@export_group("Special Behaviors")
@export var is_final_wave: bool = false
@export var spawn_boss_at_end: bool = false  # boss spawns AFTER all groups are defeated
@export var boss_stats: EnemyStats

@export_group("Presentation")
@export var wave_start_message: String = ""
@export var wave_music: AudioStream

func get_total_enemy_count() -> int:
	var total = 0
	for group in enemy_groups:
		if group:
			total += group.get_total_count()
	return total

# returns estimated total wave duration in seconds
func get_estimated_duration() -> float:
	var duration = 0.0
	for i in range(enemy_groups.size()):
		if enemy_groups[i]:
			duration += enemy_groups[i].get_spawn_duration()
			if i < enemy_groups.size() - 1:
				duration += spawn_delay_between_groups
	return duration

# weighted random modifier selection (WaveManager will call this for each enemy)
func get_random_modifier() -> EnemyStats.EnemyModifier:
	if randf() > modifier_spawn_chance:
		return EnemyStats.EnemyModifier.NONE

	var total_weight = grilled_weight + frozen_weight + rotten_weight
	if total_weight <= 0:
		return EnemyStats.EnemyModifier.NONE

	# roll against cumulative weights to pick modifier type
	var roll = randf() * total_weight
	if roll < grilled_weight:
		return EnemyStats.EnemyModifier.GRILLED
	elif roll < grilled_weight + frozen_weight:
		return EnemyStats.EnemyModifier.FROZEN
	else:
		return EnemyStats.EnemyModifier.ROTTEN

func get_summary() -> String:
	var summary = "=== Wave %d: %s ===\n" % [wave_number, wave_name]
	if description:
		summary += "%s\n" % description
	summary += "\nEnemy Groups (%d total):\n" % get_total_enemy_count()
	for group in enemy_groups:
		if group:
			summary += "  - %s" % group.get_summary()
	summary += "\nDifficulty:\n"
	summary += "  Modifier Chance: %.0f%%\n" % (modifier_spawn_chance * 100)
	if modifier_spawn_chance > 0:
		var total = grilled_weight + frozen_weight + rotten_weight
		summary += "    Grilled: %.0f%% | Frozen: %.0f%% | Rotten: %.0f%%\n" % [
			(grilled_weight / total) * 100 if total > 0 else 0,
			(frozen_weight / total) * 100 if total > 0 else 0,
			(rotten_weight / total) * 100 if total > 0 else 0
		]
	summary += "\nRewards: %d points\n" % wave_completion_bonus
	if is_final_wave and spawn_boss_at_end and boss_stats:
		summary += "\n!!! BOSS WAVE: %s !!!\n" % boss_stats.enemy_name
	summary += "\nEstimated Duration: %.1f seconds\n" % get_estimated_duration()
	return summary
