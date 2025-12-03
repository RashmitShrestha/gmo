class_name Pomegranate
extends Fruit

@export var max_dist: float
@export var animation_manager_component: PomegranateAnimationManagerComponent
@export var command_manager_component: PomegranateCommandManagerComponent
@export var reactive_component: PomegranateReactiveComponent

var full_slash = 15
var curr_command: Command
var default_command: PomegranateDefaultCommand
var shooting_command: PomegranateShootingCommand

func _ready():
	super()
	
	default_command = PomegranateDefaultCommand.new(speed)
	shooting_command = PomegranateShootingCommand.new(stun_time)


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
