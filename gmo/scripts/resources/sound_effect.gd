class_name SoundEffect
extends Resource

## Sound effect resource, used to configure unique sound effects for use with the AudioManager. Passed to [method AudioManager.create_2d_audio_at_location()] and [method AudioManager.create_audio()] to play sound effects.
##
## Stores the different types of sounds effects available to be played to distinguish them from another. Each new SoundEffect resource created should add to this enum, to allow them to be easily instantiated via [method AudioManager.create_2d_audio_at_location()] and [method AudioManager.create_audio()].

enum SOUND_EFFECT_TYPE {
	# Combat sounds
	SWORD_SWING,
	ENEMY_HIT,
	PLAYER_DAMAGE_1,
	PLAYER_DAMAGE_2,
	PLAYER_DAMAGE_3,
	PLAYER_DAMAGE_4,
	PLAYER_DAMAGE_5,
	PLAYER_DEATH_1,
	PLAYER_DEATH_2,
	PLAYER_DEATH_3,
	
	# UI sounds
	BUY_PURCHASE,
	WIN_VICTORY,
	LOSE_DEFEAT,
	
	# Wave sounds
	WAVE_START_1,
	WAVE_START_2,
	WAVE_START_3,
	WAVE_VICTORY_1,
	WAVE_VICTORY_2,
	
	# Add more sound effect types here as needed
}

@export_range(0, 10) var limit: int = 5 ## Maximum number of this SoundEffect to play simultaneously before culled.

@export var type: SOUND_EFFECT_TYPE ## The unique sound effect in the [enum SOUND_EFFECT_TYPE] to associate with this effect. Each SoundEffect resource should have it's own unique [enum SOUND_EFFECT_TYPE] setting.

@export var sound_effect: AudioStream ## The [AudioStream] audio resource to play (supports MP3, WAV, etc.).

@export_range(-40, 20) var volume: float = 0 ## The volume of the [member sound_effect].

@export_range(0.0, 4.0, 0.01) var pitch_scale: float = 1.0 ## The pitch scale of the [member sound_effect].

@export_range(0.0, 1.0, 0.01) var pitch_randomness: float = 0.0 ## The pitch randomness setting of the [member sound_effect].

var audio_count: int = 0 ## The instances of this [AudioStream] currently playing.

## Takes [param amount] to change the [member audio_count]. 
func change_audio_count(amount: int) -> void:
	audio_count = max(0, audio_count + amount)

## Checks whether the audio limit is reached. Returns true if the [member audio_count] is less than the [member limit].
func has_open_limit() -> bool:
	return audio_count < limit

## Connected to the [member sound_effect]'s finished signal to decrement the [member audio_count].
func on_audio_finished() -> void:
	change_audio_count(-1)
