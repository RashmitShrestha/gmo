class_name IdleCommand
extends Command


func execute(_character: GameCharacter) -> Status:
	_character.velocity = Vector2.ZERO
	return Status.DONE
