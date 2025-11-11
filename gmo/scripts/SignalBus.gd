class_name Signals
extends Node

# Global signal bus for communication between systems
# UI, Audio, and Logic can subscribe to these signals

# ui and logic signals
signal player_health_changed(new_health, max_health)
signal base_health_changed(new_health, max_health)

# audio n fx signal 
signal player_dashed
signal enemy_slashed

signal damage_enemy(character:GameCharacter, slice_velocity:float)

# more signals should be added here as the systems that emit them are built
# example usage:
#   to emit: SignalBus.player_dashed.emit()
#   to connect: SignalBus.player_dashed.connect(_on_player_dashed)
