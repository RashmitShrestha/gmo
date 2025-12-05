class_name Signals
extends Node

# Global signal bus for communication between systems
# UI, Audio, and Logic can subscribe to these signals

# ui and logic signals
signal player_health_changed(new_health, max_health)
signal base_health_changed(new_health, max_health)
signal player_died

# audio n fx signal 
signal player_dashed
signal enemy_slashed

signal damage_enemy(character:GameCharacter, slice_velocity:float)
signal skill_damage_enemy(character: GameCharacter, dmg: float, element: int)

# enemy signals
signal enemy_spawned(enemy_type: String, enemy_node: Node2D)
signal enemy_died(enemy_type: String, enemy_node: Node2D, drop_type: int)
signal enemy_split(parent_enemy: Node2D, split_count: int)

# wave signals
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed

# drop/reward signals
signal item_dropped(item_type: String, position: Vector2, rarity: int)
signal item_collected(item_type: String, rarity: int)

# more signals should be added here as the systems that emit them are built
# example usage:
#   to emit: SignalBus.player_dashed.emit()
#   to connect: SignalBus.player_dashed.connect(_on_player_dashed)
