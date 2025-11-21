class_name SingleGrape
extends GameCharacter


@export var stun_time: float = 1.0

@export var animation_manager_component: SingleGrapeAnimationManagerComponent
@export var command_manager_component: SingleGrapeCommandManagerComponent
@export var reactive_component: SingleGrapeReactiveComponent

var warden: Warden

var stunned: bool = false

var curr_command: Command
var default_command: SingleGrapeDefaultCommand
var stun_command: SingleGrapeStunCommand

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	warden = %Warden
	
	default_command = SingleGrapeDefaultCommand.new(speed)
	stun_command = SingleGrapeStunCommand.new(stun_time)


func _physics_process(_delta) -> void:
	reactive_component.update()
	super(_delta)


func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()
