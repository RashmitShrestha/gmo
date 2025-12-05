class_name PlayerCommandManagerComponent
extends CommandManagerComponent


func update() -> void:
	SignalBus.player_died.connect(
		func():
			_parent.curr_command = _parent.died_command
	)
	
	if _parent.curr_command == _parent.dash_command and _parent.damaged:
		_parent.curr_command.force_finish()
		_parent.curr_command = _parent.knockback_command
	elif null == _parent.curr_command:
		if _parent.damaged:
			_parent.curr_command = _parent.knockback_command
		elif _parent.direction != Vector2.ZERO:
			if Input.is_action_just_pressed("shift"):
				_parent.curr_command = _parent.dash_command
			else:
				_parent.curr_command = _parent.move_command
		else:
			_parent.curr_command = _parent.idle_command

	if Command.Status.DONE == _parent.curr_command.execute(_parent):
		_parent.curr_command = null
