class_name Strawberry
extends GameCharacter


@export var min_dist: float = 20.0
@export var max_dist: float = 50.0

@export var animation_manager_component: StrawberryAnimationManagerComponent
@export var command_manager_component: StrawberryCommandManagerComponent
@export var reactive_component: StrawberryReactiveComponent

var warden: Warden

var stunned: bool = false

var curr_command: Command
var move_in_command: StrawberryMoveInCommand
var move_out_command: StrawberryMoveOutCommand
var shoot_command: StrawberryShootCommand

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	warden = %Warden
	
	move_in_command = StrawberryMoveInCommand.new(speed)
	move_out_command = StrawberryMoveOutCommand.new(speed)
	shoot_command = StrawberryShootCommand.new()


func _physics_process(_delta) -> void:
	reactive_component.update()
	super(_delta)


func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()
