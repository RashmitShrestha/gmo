class_name DashCommand
extends Command

var _speed_curve: Curve
var _timer: Timer
var _direction: Vector2

func _init(speed_curve: Curve) -> void:
	_speed_curve = speed_curve


func execute(character: GameCharacter) -> Status:
	if _timer == null:
		_timer = Timer.new()
		character.add_child(_timer)
		_timer.one_shot = true
		_timer.start(_speed_curve.max_domain)

		_direction = character.direction

		#emit signal for audio n FX
		SignalBus.player_dashed.emit()
	
	if not _timer.is_stopped():
		character.velocity = _direction * _speed_curve.sample(_speed_curve.max_domain - _timer.time_left)
		return Status.ACTIVE
	else:
		character.velocity = Vector2.ZERO
		_timer.queue_free()
		return Status.DONE
