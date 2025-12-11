class_name CornucopiaCommandManagerComponent
extends CommandManagerComponent

var _just_attacked: bool = false
var _just_retreated: bool = false

func update():
	if null == _parent.curr_command:
		if _just_attacked:
			_parent.target = _parent.peach_tree
			_parent.curr_command = _parent.retreat_command
			_just_attacked = false
			_just_retreated = true
		elif _just_retreated:
			_parent.curr_command = _parent.wait_command
			_just_retreated = false
		else:
			if randf() < 0.5:
				_parent.target = _parent.warden
				_parent.curr_command = _parent.rush_command
			else:
				_parent.target = _parent.peach_tree
				_parent.curr_command = _parent.spawn_command
			
			_just_attacked = true

	if Command.Status.DONE == _parent.curr_command.execute(_parent):
		_parent.curr_command = null
