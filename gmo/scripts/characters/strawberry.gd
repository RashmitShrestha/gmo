class_name Strawberry
extends GameCharacter


@export var stun_time: float = 1.0

@export var animation_manager_component: StrawberryAnimationManagerComponent
@export var command_manager_component: StrawberryCommandManagerComponent
@export var reactive_component: StrawberryReactiveComponent

var warden: Warden

var stunned: bool = false

var curr_command: Command
var default_command: StrawberryDefaultCommand
var stun_command: StrawberryStunCommand

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	warden = %Warden
	
	default_command = StrawberryDefaultCommand.new(speed)
	stun_command = StrawberryStunCommand.new(stun_time)


func _physics_process(_delta) -> void:
	reactive_component.update()
	super(_delta)


func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()
