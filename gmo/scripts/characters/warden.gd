class_name Warden
extends GameCharacter

@export var dash_speed_curve: Curve

@export var command_manager_component: PlayerCommandManagerComponent
@export var input_component: PlayerInputComponent
@export var animation_manager_component: PlayerAnimationManagerComponent

@onready var animation_tree: AnimationTree = $AnimationTree

var curr_command: Command
var idle_command: PlayerIdleCommand
var move_command: PlayerMoveCommand
var dash_command: PlayerDashCommand

var vel_vec := Vector2.ZERO
var curr_vel: int = 0
var is_slicing: bool = false

var slice_radius = 300

func _ready() -> void:
	health = 100.0  # Initialize player health
	animation_tree.active = true
	idle_command = PlayerIdleCommand.new()
	move_command = PlayerMoveCommand.new()
	dash_command = PlayerDashCommand.new(dash_speed_curve)
	queue_redraw()  # Add this

func _draw():
	draw_circle(Vector2.ZERO, slice_radius, Color(1, 0, 0, 0.2))

func _input(event):
	input_component.update(event)


func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()
