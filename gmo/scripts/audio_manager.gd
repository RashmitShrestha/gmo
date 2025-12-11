extends Node2D

## Audio manager node. Intended to be globally loaded as a 2D Scene. Handles [method create_2d_audio_at_location()] and [method create_audio()] to handle the playback and culling of simultaneous sound effects.
##
## To properly use, define [enum SoundEffect.SOUND_EFFECT_TYPE] for each unique sound effect, create a Node2D scene for this AudioManager script add those SoundEffect resources to this globally loaded script's [member sound_effects], and setup your individual SoundEffect resources. Then, use [method create_2d_audio_at_location()] and [method create_audio()] to play those sound effects either at a specific location or globally.
## 
## See https://github.com/Aarimous/AudioManager for more information.
##
## @tutorial: https://www.youtube.com/watch?v=Egf2jgET3nQ

var sound_effect_dict: Dictionary = {} ## Loads all registered SoundEffects on ready as a reference.

@export var sound_effects: Array[SoundEffect] ## Stores all possible SoundEffects that can be played.

func _ready() -> void:
	for sound_effect: SoundEffect in sound_effects:
		sound_effect_dict[sound_effect.type] = sound_effect

## Creates a sound effect at a specific location if the limit has not been reached. Pass [param location] for the global position of the audio effect, and [param type] for the SoundEffect to be queued.
func create_2d_audio_at_location(location: Vector2, type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		
		if sound_effect.has_open_limit():
			sound_effect.change_audio_count(1)
			
			var new_2D_audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
			add_child(new_2D_audio)
			
			new_2D_audio.position = location
			new_2D_audio.stream = sound_effect.sound_effect
			new_2D_audio.volume_db = sound_effect.volume
			new_2D_audio.pitch_scale = sound_effect.pitch_scale
			new_2D_audio.pitch_scale += randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness)
			
			new_2D_audio.finished.connect(sound_effect.on_audio_finished)
			new_2D_audio.finished.connect(new_2D_audio.queue_free)
			new_2D_audio.play()
	else:
		push_error("Audio Manager failed to find setting for type ", type)

## Creates a sound effect if the limit has not been reached. Pass [param type] for the SoundEffect to be queued.
func create_audio(type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		
		if sound_effect.has_open_limit():
			sound_effect.change_audio_count(1)
			
			var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
			add_child(new_audio)
			
			new_audio.stream = sound_effect.sound_effect
			new_audio.volume_db = sound_effect.volume
			new_audio.pitch_scale = sound_effect.pitch_scale
			new_audio.pitch_scale += randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness)
			
			new_audio.finished.connect(sound_effect.on_audio_finished)
			new_audio.finished.connect(new_audio.queue_free)
			new_audio.play()
	else:
		push_error("Audio Manager failed to find setting for type ", type)

## Plays a random player damage sound from the available PLAYER_DAMAGE_1 through PLAYER_DAMAGE_5 types.
func create_random_player_damage_audio() -> void:
	var damage_types = [
		SoundEffect.SOUND_EFFECT_TYPE.PLAYER_DAMAGE_1,
		SoundEffect.SOUND_EFFECT_TYPE.PLAYER_DAMAGE_2,
		SoundEffect.SOUND_EFFECT_TYPE.PLAYER_DAMAGE_3,
		SoundEffect.SOUND_EFFECT_TYPE.PLAYER_DAMAGE_4,
		SoundEffect.SOUND_EFFECT_TYPE.PLAYER_DAMAGE_5,
	]
	
	# Filter to only include types that are actually registered
	var available_types = []
	for type in damage_types:
		if sound_effect_dict.has(type):
			available_types.append(type)
	
	if available_types.is_empty():
		push_error("Audio Manager: No player damage sounds registered")
		return
	
	# Pick a random available type
	var random_type = available_types[randi() % available_types.size()]
	create_audio(random_type)

## Plays a random player death sound from the available PLAYER_DEATH_1 through PLAYER_DEATH_3 types.
func create_random_player_death_audio() -> void:
	var death_types = [
		SoundEffect.SOUND_EFFECT_TYPE.PLAYER_DEATH_1,
		SoundEffect.SOUND_EFFECT_TYPE.PLAYER_DEATH_2,
		SoundEffect.SOUND_EFFECT_TYPE.PLAYER_DEATH_3,
	]
	
	# Filter to only include types that are actually registered
	var available_types = []
	for type in death_types:
		if sound_effect_dict.has(type):
			available_types.append(type)
	
	if available_types.is_empty():
		push_error("Audio Manager: No player death sounds registered")
		return
	
	# Pick a random available type
	var random_type = available_types[randi() % available_types.size()]
	create_audio(random_type)
