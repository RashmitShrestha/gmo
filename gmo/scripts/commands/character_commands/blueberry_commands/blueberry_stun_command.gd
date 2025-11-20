class_name BlueberryStunCommand
extends Command

var _timer: Timer
var _stun_time: float

func _init(stun_time: float):
	_stun_time = stun_time


func execute(character: Blueberry) -> Status:
	if _timer == null:
		_timer = Timer.new()
		character.add_child(_timer)
		_timer.one_shot = true
		_timer.start(_stun_time)
		
		character.velocity = Vector2.ZERO
		character.direction = Vector2.ZERO
	
	if not _timer.is_stopped():
		return Status.ACTIVE
	else:
		character.stunned = false
		_timer.queue_free()
		return Status.DONE
