class_name Signals
extends Node


# ui and logic signals
signal player_health_changed(new_health, max_health)
signal base_health_changed(new_health, max_health)
signal player_died

# audio n fx signal 
signal player_dashed
signal enemy_slashed

signal damage_enemy(character:GameCharacter, slice_velocity:float)
# Health signals
signal health_restored(character: GameCharacter, amount: float)
# enemy signals
signal enemy_spawned(enemy_type: String, enemy_node: Node2D)
signal enemy_died(enemy_type: String, enemy_node: Node2D, drop_type: int)
signal enemy_split(parent_enemy: Node2D, split_count: int)

signal char_damaged_char(source: GameCharacter, target: GameCharacter)

# wave signals
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed

# drop/reward signals
signal item_dropped(item_type: String, position: Vector2, rarity: int)
signal item_collected(item_type: String, rarity: int)

# skill tree upgrade signals
signal stat_modified(character_group: String, stat_name: String, value: float)
# character_group: "player" or "enemies"
# stat_name: "attack", "movement_speed", "max_health", etc.
# value: the new value or multiplier
# is_multiplier: true if it's a percentage boost (1.10 = +10%), false if flat value

# === ABILITY TOGGLES ===
signal ability_toggled(ability_id: String, enabled: bool, parameters: Dictionary)
# ability_id: "flame_trail", "frost_trail", "blowtorch", "freeze_frame", etc.
# enabled: true/false
# parameters: ability-specific settings like duration, damage, range

# === STATUS EFFECTS ===
signal status_effect_applied(character_group: String, effect_name: String, parameters: Dictionary)
# character_group: "player" or "enemies"
# effect_name: "burn_crit_boost", "consecutive_hit", "health_regen", etc.

# more signals should be added here as the systems that emit them are built
# example usage:
#   to emit: SignalBus.player_dashed.emit()
#   to connect: SignalBus.player_dashed.connect(_on_player_dashed)
