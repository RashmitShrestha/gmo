class_name Grape
extends GameCharacter


@export var stun_time: float = 1.0

@export var animation_manager_component: GrapeAnimationManagerComponent
@export var command_manager_component: GrapeCommandManagerComponent
@export var reactive_component: GrapeReactiveComponent

var warden: Warden

var stunned: bool = false

var curr_command: Command
var default_command: GrapeDefaultCommand
var stun_command: GrapeStunCommand

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	warden = %Warden
	
	default_command = GrapeDefaultCommand.new(speed)
	stun_command = GrapeStunCommand.new(stun_time)


func _physics_process(_delta) -> void:
	reactive_component.update()
	super(_delta)


func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()
