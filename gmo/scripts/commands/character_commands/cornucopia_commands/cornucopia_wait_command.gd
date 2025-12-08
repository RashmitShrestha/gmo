class_name CornucopiaWaitCommand
extends Command

var _time: float
var _timer: Timer

func _init(time: float) -> void:
	_time = time


func execute(character: Cornucopia) -> Status:
	if _timer == null:
		character.is_attacking = false
		_timer = Timer.new()
		_timer.one_shot = true
		character.add_child(_timer)
		_timer.start(_time)
	
	if not _timer.is_stopped():
		character.velocity = Vector2.ZERO
		return Command.Status.ACTIVE
	else:
		_timer.queue_free()
		return Command.Status.DONE
