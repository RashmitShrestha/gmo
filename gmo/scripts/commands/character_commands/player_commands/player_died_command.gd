class_name PlayerDiedCommand
extends Command

var _respawn_time: float
var _respawn_point: Vector2
var _timer: Timer

func _init(respawn_time: float, respawn_point: Vector2) -> void:
	_respawn_time = respawn_time
	_respawn_point = respawn_point


func execute(character: Warden) -> Status:
	if _timer == null:
		character.damaged = false
		character.make_invulnerable(_respawn_time + 1.0)
		character.velocity = Vector2.ZERO
		
		_timer = Timer.new()
		character.add_child(_timer)
		_timer.one_shot = true
		_timer.start(_respawn_time)
	
	if _timer.is_stopped():
		character.position = _respawn_point
		character.heal(character.max_health)
		SignalBus.player_health_changed.emit(character.max_health, character.max_health)
		character.blink(1.0)
		_timer.queue_free()
		return Status.DONE

	return Status.ACTIVE


func force_finish() -> void:
	_timer.queue_free()
