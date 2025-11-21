class_name GrapeCommandManagerComponent
extends CommandManagerComponent

func update():
	if null == _parent.curr_command:
		if not _parent.stunned:
			_parent.curr_command = _parent.default_command
		else:
			_parent.curr_command = _parent.stun_command

	if Command.Status.DONE == _parent.curr_command.execute(_parent):
		_parent.curr_command = null
