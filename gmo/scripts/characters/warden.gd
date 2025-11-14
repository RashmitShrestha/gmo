class_name Warden
extends GameCharacter

@export var dash_speed_curve: Curve

@onready var animation_tree: AnimationTree = $AnimationTree

var _curr_command: Command
var _idle_command: IdleCommand
var _move_command: MoveCommand
var _dash_command: DashCommand
var _damaged:bool = false

var vel_vec = Vector2.ZERO
var curr_vel = 0
var is_slicing = false


func _ready() -> void:
	animation_tree.active = true
	_idle_command = IdleCommand.new()
	_move_command = MoveCommand.new()
	_dash_command = DashCommand.new(dash_speed_curve)
	

func _input(event):
	if Input.is_action_pressed("left_click"):
		if event is InputEventMouseMotion:
			is_slicing = true
			vel_vec = event.relative
			curr_vel = abs(Vector2.ZERO.distance_to(vel_vec))
			
			# tweak to find the best number for "full velocity hits" 
			#if curr_vel > 25:
				#print("F") # fast
			#elif curr_vel > 7.5:
				#print("M") # medium
			#else: 
				#print("S") # slow
			
			%Slice.slicing()
	else:
		is_slicing = false
		%Slice.clear_points()
		%Slice.points_queue = []
		
		
func _process(_delta) -> void:
	update_animation_parameters()
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


func update_animation_parameters():
	if(velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else: 
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
		
	if _damaged:
		animation_tree["parameters/conditions/hurt"] = true
		_damaged = false
	else: 
		animation_tree["parameters/conditions/hurt"] = false
	
	if direction != Vector2.ZERO:
		animation_tree["parameters/Run/blend_position"] = direction
