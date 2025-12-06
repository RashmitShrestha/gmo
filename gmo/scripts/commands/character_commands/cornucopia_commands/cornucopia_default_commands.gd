class_name CornucopiaDefaultCommand
extends Command

var _speed: float

func _init(speed: float) -> void:
	_speed = speed


func execute(character: Cornucopia) -> Status:
	character.velocity = _speed * character.direction
	return Command.Status.DONE
