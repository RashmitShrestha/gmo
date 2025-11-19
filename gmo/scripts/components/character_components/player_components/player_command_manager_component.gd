class_name PlayerCommandManagerComponent
extends CommandManagerComponent


func update(character: Warden) -> void:
	if null == character.curr_command:
		if character.direction != Vector2.ZERO:
			if Input.is_action_just_pressed("shift"):
				character.curr_command = character.dash_command
			else:
				character.curr_command = character.move_command
		else:
			character.curr_command = character.idle_command

	if Command.Status.DONE == character.curr_command.execute(character):
		character.curr_command = null
