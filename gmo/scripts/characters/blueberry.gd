class_name Blueberry
extends Fruit

@export var animation_manager_component: BlueberryAnimationManagerComponent
@export var command_manager_component: BlueberryCommandManagerComponent
@export var reactive_component: BlueberryReactiveComponent
@export var knockback_curve: Curve

var curr_command: Command
var default_command: BlueberryDefaultCommand
var knockback_command: KnockbackCommand

func _ready():
	super()
	
	default_command = BlueberryDefaultCommand.new(speed)
	knockback_command = KnockbackCommand.new(knockback_curve, self)


func _physics_process(_delta) -> void:
	reactive_component.update()
	super(_delta)


func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()
