class_name CornucopiaRetreatCommand
extends Command

var _speed: float
var _timer: Timer

func _init(speed: float) -> void:
	_speed = speed


func execute(character: Cornucopia) -> Status:
	if _timer == null:
		character.is_attacking = false
		_timer = Timer.new()
		_timer.one_shot = true
		character.add_child(_timer)
		_timer.start(3.0)

	if not _timer.is_stopped():
		if (character.position - character.peach_tree.position).length() < 750:
			character.velocity = _speed * (character.position - character.peach_tree.position).normalized()
		elif (character.position - character.peach_tree.position).length() > 800:
			character.velocity = -_speed * (character.position - character.peach_tree.position).normalized()
		else:
			character.velocity = Vector2.ZERO
			_timer.queue_free()
			_timer = null
			
			return Command.Status.DONE
		return Command.Status.ACTIVE
	else:
		_timer.queue_free()
		return Command.Status.DONE
