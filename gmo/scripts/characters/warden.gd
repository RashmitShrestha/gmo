class_name Warden
extends GameCharacter

@export var dash_speed_curve: Curve
@export var command_manager_component: PlayerCommandManagerComponent
@export var input_component: PlayerInputComponent

@onready var animation_tree: AnimationTree = $AnimationTree

var curr_command: Command
var idle_command: IdleCommand
var move_command: MoveCommand
var dash_command: DashCommand
var _damaged:bool = false

var vel_vec = Vector2.ZERO
var curr_vel = 0
var is_slicing = false

func _ready() -> void:
	animation_tree.active = true
	idle_command = IdleCommand.new()
	move_command = MoveCommand.new()
	dash_command = DashCommand.new(dash_speed_curve)


func _input(event):
	input_component.update(self, event)


func _process(_delta) -> void:
	command_manager_component.update(self)


func update_animation_parameters():
	if (velocity == Vector2.ZERO):
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
