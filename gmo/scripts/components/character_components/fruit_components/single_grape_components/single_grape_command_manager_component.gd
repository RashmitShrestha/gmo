class_name SingleGrapeCommandManagerComponent
extends CommandManagerComponent


func _init() -> void:
	SignalBus.char_damaged_char.connect(_on_damage)


func _on_damage(source: GameCharacter, target: GameCharacter):
	if source == _parent and (target is Warden or target is PeachTree):
		_parent.curr_command = _parent.knockback_command


func update():
	if null == _parent.curr_command:
		if not _parent.stunned:
			_parent.curr_command = _parent.default_command
		else:
			_parent.curr_command = _parent.stun_command

	if Command.Status.DONE == _parent.curr_command.execute(_parent):
		_parent.curr_command = null
