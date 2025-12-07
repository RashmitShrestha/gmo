class_name PomegranateCommandManagerComponent
extends CommandManagerComponent

func update():
	if null == _parent.curr_command:
		if _parent.target.position.distance_to(_parent.position) > _parent.max_dist:
			_parent.curr_command = _parent.default_command
		else:
			_parent.curr_command = _parent.shooting_command

	if Command.Status.DONE == _parent.curr_command.execute(_parent):
		_parent.curr_command = null
