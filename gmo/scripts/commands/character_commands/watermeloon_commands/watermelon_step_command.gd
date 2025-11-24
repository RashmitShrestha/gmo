class_name WatermelonStepCommand
extends Command

var _timer: Timer
var _speed: float
var _duration: float
var _curr_direction: Vector2

func _init(speed: float, duration: float):
	_speed = speed
	_duration = duration


func execute(character: Watermelon) -> Status:
	if _timer == null:
		_timer = Timer.new()
		character.add_child(_timer)
		_timer.one_shot = true
		_timer.start(_duration)
		
		_curr_direction = character.direction
	
	if not _timer.is_stopped():
		character.velocity = _speed * _curr_direction
		return Status.ACTIVE
	else:
		character.stunned = true
		_timer.queue_free()
		return Status.DONE
