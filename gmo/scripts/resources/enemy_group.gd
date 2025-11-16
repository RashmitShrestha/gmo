# resource for defining a group of enemies that spawn together in a wave
class_name EnemyGroup extends Resource

enum SpawnPattern {
	RANDOM_PERIMETER,  # spawn randomly around map perimeter
	CLUSTER,           # spawn in a tight group at one location
	LINE,              # spawn in a line formation
	CIRCLE,            # spawn in a circle formation
	SPREAD             # spawn evenly distributed around perimeter
}

@export var group_name: String = "Enemy Group"
@export_multiline var description: String = ""

@export_group("Enemy Configuration")
@export var enemy_stats: EnemyStats
@export var count: int = 1

@export_group("Spawn Behavior")
@export var spawn_pattern: SpawnPattern = SpawnPattern.RANDOM_PERIMETER
@export var spawn_delay: float = 0.0
@export var spawn_interval: float = 0.2  # time between each individual enemy spawning

@export_group("Modifiers")
@export var force_modifier: EnemyStats.EnemyModifier = EnemyStats.EnemyModifier.NONE  # overrides wave's random modifier system
@export var modifier_chance: float = 0.0

func get_total_count() -> int:
	return count

func get_spawn_duration() -> float:
	return spawn_delay + (spawn_interval * max(0, count - 1))

func get_summary() -> String:
	var summary = "%s: %d x %s\n" % [
		group_name,
		count,
		enemy_stats.enemy_name if enemy_stats else "None"
	]
	summary += "Pattern: %s | Delay: %.1fs\n" % [
		SpawnPattern.keys()[spawn_pattern],
		spawn_delay
	]
	if force_modifier != EnemyStats.EnemyModifier.NONE:
		summary += "Forced Modifier: %s\n" % EnemyStats.EnemyModifier.keys()[force_modifier]
	return summary
