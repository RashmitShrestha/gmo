class_name PlayerIdleCommand
extends Command


func execute(character: Warden) -> Status:
	character.velocity = Vector2.ZERO
	return Status.DONE
