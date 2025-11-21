class_name SingleGrapeDefaultCommand
extends Command

var _speed: float

func _init(speed: float) -> void:
	_speed = speed


func execute(character: SingleGrape) -> Status:
	character.velocity = _speed * character.direction
	return Command.Status.DONE
