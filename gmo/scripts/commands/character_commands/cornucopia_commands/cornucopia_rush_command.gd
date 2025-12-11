class_name CornucopiaRushCommand
extends Command

var _speed: float
var _timer: Timer
var _starting_health: float
var _done: bool = false

func _init(speed: float, cornucopia: Cornucopia) -> void:
	_speed = speed
	SignalBus.char_damaged_char.connect(
		func(source: GameCharacter, _target: GameCharacter):
			if source == cornucopia and cornucopia.curr_command == cornucopia.rush_command:
				_done = true
	)


func execute(character: Cornucopia) -> Status:
	if _timer == null:
		_done = false
		_starting_health = character.curr_health
		character.is_attacking = true
		_timer = Timer.new()
		_timer.one_shot = true
		character.add_child(_timer)
		_timer.start(10.0)
		
	character.velocity = _speed * character.direction * pow(10.0 - _timer.time_left, 2) / 10.0
	
	if _starting_health - character.curr_health >= 500 or \
		_timer.is_stopped() or \
		_done:
		character.is_attacking = false
		_done = true
		_timer.queue_free()
		return Command.Status.DONE
	else:
		return Command.Status.ACTIVE
