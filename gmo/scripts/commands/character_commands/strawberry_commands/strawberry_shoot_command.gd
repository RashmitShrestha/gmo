class_name StrawberryShootCommand
extends Command


func execute(_character: Strawberry) -> Status:
	_character.velocity = Vector2.ZERO
	return Command.Status.DONE
