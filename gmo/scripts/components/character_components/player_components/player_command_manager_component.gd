class_name PlayerCommandManagerComponent
extends CommandManagerComponent


func update() -> void:
	if null == _parent.curr_command:
		if _parent.direction != Vector2.ZERO:
			if Input.is_action_just_pressed("shift"):
				_parent.curr_command = _parent.dash_command
			else:
				_parent.curr_command = _parent.move_command
		else:
			_parent.curr_command = _parent.idle_command

	if Command.Status.DONE == _parent.curr_command.execute(_parent):
		_parent.curr_command = null
