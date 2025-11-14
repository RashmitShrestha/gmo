class_name MoveCommand
extends Command


func execute(character: GameCharacter) -> Status:
	character.velocity = character.direction * character.speed
	if character.direction.x < 0:
		character.sprite.flip_h = true
	else:
		character.sprite.flip_h = false
	return Status.DONE
