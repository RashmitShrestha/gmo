class_name PlayerKnockbackCommand
extends Command

var _timer: Timer
var _speed_curve: Curve
var _direction: Vector2
var _damaged_from: Vector2

func _init(speed_curve: Curve, character: Warden):
	_speed_curve = speed_curve
	character.received_damage.connect(
		func(_damage: float, source: Node2D):
			_damaged_from = source.position
	)


func execute(character: Warden) -> Status:
	if _timer == null:
		_timer = Timer.new()
		character.add_child(_timer)
		_timer.one_shot = true
		_timer.start(_speed_curve.max_domain)
		
		_direction = (character.position - _damaged_from).normalized()

	if not _timer.is_stopped():
		character.velocity = _direction * _speed_curve.sample(_speed_curve.max_domain - _timer.time_left)
		return Status.ACTIVE
	else:
		character.velocity = Vector2.ZERO
		_timer.queue_free()
		return Status.DONE
