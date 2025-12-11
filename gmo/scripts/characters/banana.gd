class_name Banana
extends Fruit

@export var animation_manager_component: BananaAnimationManagerComponent
@export var command_manager_component: BananaCommandManagerComponent
@export var reactive_component: BananaReactiveComponent
@export var projectile_speed: float
@export var frequency: float
@export var max_dist: float

var full_slash = 5
var curr_command: Command
var default_command: BananaDefaultCommand
var shoot_command: BananaShootCommand

@onready var projectile: PackedScene = preload("res://scenes/aoe_seed.tscn")

func _ready():
	super()
	
	default_command = BananaDefaultCommand.new(speed)
	shoot_command = BananaShootCommand.new(projectile, projectile_speed, frequency)


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
