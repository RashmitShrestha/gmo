# resource for defining enemy data. create .tres files instead of writing code
class_name EnemyStats extends Resource

enum AttackType {
	NONE,        # doesn't attack
	MELEE,       # bumps into target
	PROJECTILE,  # straight line shots
	HOMING,      # tracking projectiles
	AOE,         # damage around enemy
	MACHINE_GUN  # burst fire with cooldown
}

enum DropType {
	LOW,     # low quantity, common rarity
	MEDIUM,  # medium quantity, mixed rarity
	HIGH     # high quantity, rare drops
}

enum SpecialBehavior {
	NONE,         # no special behavior
	SPLIT,        # breaks into smaller enemies on death
	BURN_AURA,    # damages nearby enemies over time
	DEFENSE_AURA, # buffs nearby enemy defense
	SECOND_LIFE,  # revives once, creates damaging aoe on final death
	EXPLODE       # explodes on projectile hit or death
}

enum EnemyModifier {
	NONE,    # no modifier
	GRILLED, # fire: faster, inflicts burn
	FROZEN,  # ice: slower, buffs allies, inflicts freeze
	ROTTEN   # poison: second life, damaging aoe
}

enum TargetPriority {
	PLAYER,      # always targets player
	BASE,        # always targets base
	CLOSEST,     # targets closest
	PLAYER_FIRST # player first, then base if dead
}

@export var enemy_name: String = "New Enemy"
@export_multiline var description: String = ""

@export_group("Combat Stats")
@export var max_health: int = 10  # health in full-velocity slashes
@export var base_damage: float = 5.0  # percentage of player health (or absolute if boss)
@export var is_boss: bool = false  # if true, damage is absolute not percentage

@export_group("Movement")
@export var movement_speed: float = 50.0  # pixels per second
@export var target_priority: TargetPriority = TargetPriority.CLOSEST

@export_group("Attack")
@export var attack_type: AttackType = AttackType.MELEE
@export var attack_cooldown: float = 2.0  # seconds between attacks
@export var attack_range: float = 50.0  # distance to attack from
@export var projectile_speed: float = 150.0  # used for projectile/homing
@export var projectile_count: int = 1  # projectiles per attack
@export var machine_gun_burst: int = 10  # shots per burst for machine gun

@export_group("Special Behaviors")
@export var special_behavior: SpecialBehavior = SpecialBehavior.NONE
@export var split_count: int = 3  # enemies spawned on split
@export var split_enemy_stats: EnemyStats  # stats for split enemies
@export var aoe_radius: float = 100.0  # radius for aoe effects
@export var aoe_damage: float = 15.0  # aoe damage (percentage)

@export_group("Modifiers")
@export var modifier: EnemyModifier = EnemyModifier.NONE
@export var modifier_speed_multiplier: float = 1.0  # speed multiplier from modifier
@export var modifier_effect_duration: float = 3.0  # burn/freeze duration in seconds

@export_group("Rewards")
@export var drop_type: DropType = DropType.LOW
@export var score_value: int = 10  # points for killing

@export_group("Scene Configuration")
@export_file("*.tscn") var scene_path: String = ""  ## this needs to be added later, should be the path to enemy scene file


@export_group("Presentation")
@export var sprite_texture: Texture2D  # main sprite
@export var death_sound: AudioStream  # plays on death
@export var attack_sound: AudioStream  # plays on attack
@export var spawn_sound: AudioStream  # plays when spawned

# converts percentage damage to actual damage (or returns absolute if boss)
func get_actual_damage(player_max_health: float) -> float:
	if is_boss:
		return base_damage
	else:
		return (base_damage / 100.0) * player_max_health

# returns speed with modifier applied
func get_modified_speed() -> float:
	return movement_speed * modifier_speed_multiplier

# returns debug summary of enemy stats
func get_summary() -> String:
	var summary = "%s\n" % enemy_name
	summary += "Health: %d slashes | Damage: %.1f%s\n" % [
		max_health,
		base_damage,
		"%" if not is_boss else " HP"
	]
	summary += "Attack: %s | Drops: %s\n" % [
		AttackType.keys()[attack_type],
		DropType.keys()[drop_type]
	]
	if modifier != EnemyModifier.NONE:
		summary += "Modifier: %s\n" % EnemyModifier.keys()[modifier]
	if special_behavior != SpecialBehavior.NONE:
		summary += "Special: %s\n" % SpecialBehavior.keys()[special_behavior]
	return summary
