class_name Blueberry
extends Fruit

@export var animation_manager_component: BlueberryAnimationManagerComponent
@export var command_manager_component: BlueberryCommandManagerComponent
@export var reactive_component: BlueberryReactiveComponent

var curr_command: Command
var default_command: BlueberryDefaultCommand
var stun_command: BlueberryStunCommand

func _ready():
	super()
	
	default_command = BlueberryDefaultCommand.new(speed)
	stun_command = BlueberryStunCommand.new(stun_time)


func _physics_process(_delta) -> void:
	reactive_component.update()
	super(_delta)


func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()
'''
func _die():
	print(str(self) + " has been defeated!")
	
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	
	queue_free()
'''
