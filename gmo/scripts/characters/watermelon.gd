class_name Watermelon
extends GameCharacter


@export var stun_time: float = 1.0

@export var animation_manager_component: WatermelonAnimationManagerComponent
@export var command_manager_component: WatermelonCommandManagerComponent
@export var reactive_component: WatermelonReactiveComponent

var warden: Warden

var stunned: bool = false

var curr_command: Command
var default_command: WatermelonDefaultCommand
var stun_command: WatermelonStunCommand

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	warden = %Warden
	
	default_command = WatermelonDefaultCommand.new(speed)
	stun_command = WatermelonStunCommand.new(stun_time)


func _physics_process(_delta) -> void:
	reactive_component.update()
	super(_delta)


func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()
