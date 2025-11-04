class_name MoveCommand
extends Command


func execute(character: GameCharacter) -> Status:
	character.velocity = character.direction * character.speed
	return Status.DONE
