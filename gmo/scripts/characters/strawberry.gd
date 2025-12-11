class_name Strawberry
extends Fruit

@export var min_dist: float = 20.0
@export var max_dist: float = 50.0
@export var projectile: PackedScene
@export var shot_speed: float
@export var frequency: float
@export var animation_manager_component: StrawberryAnimationManagerComponent
@export var command_manager_component: StrawberryCommandManagerComponent
@export var reactive_component: StrawberryReactiveComponent

var curr_command: Command
var move_in_command: StrawberryMoveInCommand
var move_out_command: StrawberryMoveOutCommand
var shoot_command: StrawberryShootCommand

func _ready():
	super()
	
	move_in_command = StrawberryMoveInCommand.new(speed)
	move_out_command = StrawberryMoveOutCommand.new(speed)
	shoot_command = StrawberryShootCommand.new(projectile, shot_speed, frequency)


func _physics_process(_delta) -> void:
	super(_delta)
	reactive_component.update()


func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()


'''
func _die():
	print(str(self) + " has been defeated!")

	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)

	super()

'''
