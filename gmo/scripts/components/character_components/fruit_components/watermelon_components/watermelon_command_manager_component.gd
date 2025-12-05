class_name WatermelonCommandManagerComponent
extends CommandManagerComponent

func _init() -> void:
	SignalBus.char_damaged_char.connect(
		func(source: GameCharacter, target: GameCharacter):
			if source == _parent and target is Warden:
				if _parent.curr_command:
					_parent.curr_command.force_finish()
				_parent.curr_command = _parent.knockback_command
	)


func update():
	if null == _parent.curr_command:
		if not _parent.stunned:
			_parent.curr_command = _parent.step_command
		else:
			_parent.curr_command = _parent.stun_command

	if Command.Status.DONE == _parent.curr_command.execute(_parent):
		_parent.curr_command = null
