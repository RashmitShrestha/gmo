class_name Watermelon
extends Fruit

@export var step_time: float = 0.2
@export var animation_manager_component: WatermelonAnimationManagerComponent
@export var command_manager_component: WatermelonCommandManagerComponent
@export var reactive_component: WatermelonReactiveComponent

var full_slash = 45
var curr_command: Command
var step_command: WatermelonStepCommand
var stun_command: WatermelonStunCommand

func _ready():
	super()

	max_health = 100 * full_slash  # 1000 HP
	curr_health = max_health
	
	step_command = WatermelonStepCommand.new(speed, step_time)
	stun_command = WatermelonStunCommand.new(stun_time)


func _physics_process(_delta) -> void:
	reactive_component.update()
	super(_delta)

func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()


func _die():
	print(str(self) + " has been defeated!")
	
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	
	queue_free()
