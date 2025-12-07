class_name BananaCommandManagerComponent
extends CommandManagerComponent

func update():
	if null == _parent.curr_command:
		if _parent.position.distance_to(_parent.target.position) > _parent.max_dist:
			_parent.curr_command = _parent.default_command
		else:
			_parent.curr_command = _parent.shoot_command

	if Command.Status.DONE == _parent.curr_command.execute(_parent):
		_parent.curr_command = null
