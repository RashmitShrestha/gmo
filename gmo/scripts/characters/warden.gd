class_name Warden
extends GameCharacter

@export var dash_speed_curve: Curve

@export var command_manager_component: PlayerCommandManagerComponent
@export var input_component: PlayerInputComponent
@export var animation_manager_component: PlayerAnimationManagerComponent

@onready var animation_tree: AnimationTree = $AnimationTree

var curr_command: Command
var idle_command: IdleCommand
var move_command: MoveCommand
var dash_command: DashCommand

var vel_vec := Vector2.ZERO
var curr_vel: int = 0
var is_slicing: bool = false

func _ready() -> void:
	animation_tree.active = true
	idle_command = IdleCommand.new()
	move_command = MoveCommand.new()
	dash_command = DashCommand.new(dash_speed_curve)


func _input(event):
	input_component.update(self, event)


func _process(_delta) -> void:
	command_manager_component.update(self)
	animation_manager_component.update(self)
