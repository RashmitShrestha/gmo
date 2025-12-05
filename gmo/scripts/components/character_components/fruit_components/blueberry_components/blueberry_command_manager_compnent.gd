class_name BlueberryCommandManagerComponent
extends CommandManagerComponent

func _init() -> void:
	SignalBus.char_damaged_char.connect(
		func(source: GameCharacter, target: GameCharacter):
			if source == _parent and target is Warden:
				_parent.curr_command = _parent.knockback_command
	)


func update():
	if null == _parent.curr_command:
		_parent.curr_command = _parent.default_command

	if Command.Status.DONE == _parent.curr_command.execute(_parent):
		_parent.curr_command = null
