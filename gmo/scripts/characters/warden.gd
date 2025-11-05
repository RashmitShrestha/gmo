class_name Warden
extends GameCharacter

@export var dash_speed_curve: Curve

var _curr_command: Command
var _idle_command: IdleCommand
var _move_command: MoveCommand
var _dash_command: DashCommand

func _ready() -> void:
	_idle_command = IdleCommand.new()
	_move_command = MoveCommand.new()
	_dash_command = DashCommand.new(dash_speed_curve)
	

func _input(event):
	if Input.is_action_pressed("left_click"):
		if event is InputEventMouseMotion:
			print(event.position)
		
		
func _process(_delta) -> void:
	_calculate_direction()
	if null == _curr_command:
		_choose_command()
	
	if Command.Status.DONE == _curr_command.execute(self):
		_curr_command = null


func _calculate_direction():
	direction = Vector2(
		int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
		int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	).normalized()
	

func _choose_command():
	if direction != Vector2.ZERO:
		if Input.is_action_just_pressed("shift"):
			_curr_command = _dash_command
		else:
			_curr_command = _move_command
	else:
		_curr_command = _idle_command
