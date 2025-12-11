class_name CornucopiaCommandManagerComponent
extends CommandManagerComponent

var _just_attacked: bool = false
var _just_retreated: bool = false

func update():
	if null == _parent.curr_command:
		if _just_attacked and not _just_retreated:
			_just_attacked = false
			_just_retreated = true
			_parent.target = _parent.peach_tree
			_parent.curr_command = _parent.retreat_command
		elif not _just_attacked and _just_retreated:
			_just_attacked = false
			_just_retreated = false
			_parent.curr_command = _parent.wait_command
		else:
			_just_attacked = true
			_just_retreated = false
			
			if randf() < 0.5:
				_parent.target = _parent.warden
				_parent.curr_command = _parent.rush_command
			else:
				_parent.target = _parent.peach_tree
				_parent.curr_command = _parent.spawn_command

	if Command.Status.DONE == _parent.curr_command.execute(_parent):
		_parent.curr_command = null
