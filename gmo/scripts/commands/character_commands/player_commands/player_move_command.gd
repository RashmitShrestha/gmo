class_name PlayerMoveCommand
extends Command


func execute(character: Warden) -> Status:
	character.velocity = character.direction * character.base_speed
	character.move_and_slide()

	if character.direction.x < 0:
		character.sprite.flip_h = true
	else:
		character.sprite.flip_h = false
	
	character.last_facing_direction = character.direction
	return Status.DONE
