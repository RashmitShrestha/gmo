class_name Banana
extends Fruit

@export var animation_manager_component: BananaAnimationManagerComponent
@export var command_manager_component: BananaCommandManagerComponent
@export var reactive_component: BananaReactiveComponent

var full_slash = 5
var curr_command: Command
var default_command: BananaDefaultCommand
var stun_command: BananaStunCommand


func _ready():
	super()

	max_health = 100 * full_slash  # 500 HP
	curr_health = max_health
	
	default_command = BananaDefaultCommand.new(speed)
	stun_command = BananaStunCommand.new(stun_time)

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
