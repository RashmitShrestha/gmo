class_name PlayerMoveCommand
extends Command


func execute(character: Warden) -> Status:
	character.velocity = character.direction * character.speed
	character.move_and_slide()

	if character.direction.x < 0:
		character.sprite.flip_h = true
	else:
		character.sprite.flip_h = false
	return Status.DONE
