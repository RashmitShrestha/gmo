class_name Pomegranate
extends GameCharacter

@export var max_dist: float
@export var stun_time: float = 1.0

@export var animation_manager_component: PomegranateAnimationManagerComponent
@export var command_manager_component: PomegranateCommandManagerComponent
@export var reactive_component: PomegranateReactiveComponent

var warden: Warden

var stunned: bool = false

var curr_command: Command
var default_command: PomegranateDefaultCommand
var shooting_command: PomegranateShootingCommand

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	warden = %Warden
	
	default_command = PomegranateDefaultCommand.new(speed)
	shooting_command = PomegranateShootingCommand.new(stun_time)


func _physics_process(_delta) -> void:
	reactive_component.update()
	super(_delta)


func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()
