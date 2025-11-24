class_name StrawberryMoveOutCommand
extends Command

var _speed: float

func _init(speed: float):
	_speed = speed


func execute(character: Strawberry) -> Status:
	character.velocity = -_speed * character.direction
	return Command.Status.DONE
