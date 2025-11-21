class_name BananaDefaultCommand
extends Command

var _speed: float

func _init(speed: float) -> void:
	_speed = speed


func execute(character: Banana) -> Status:
	character.velocity = _speed * character.direction
	return Command.Status.DONE
