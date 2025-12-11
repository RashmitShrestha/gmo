class_name StrawberryCommandManagerComponent
extends CommandManagerComponent


func update():
	if null == _parent.curr_command:
		var dist = _parent.target.position.distance_to(_parent.position)
		
		if dist > _parent.max_dist:
			_parent.curr_command = _parent.move_in_command
		elif dist < _parent.min_dist:
			_parent.curr_command = _parent.move_out_command
		else:
			_parent.curr_command = _parent.shoot_command

	if Command.Status.DONE == _parent.curr_command.execute(_parent):
		_parent.curr_command = null
