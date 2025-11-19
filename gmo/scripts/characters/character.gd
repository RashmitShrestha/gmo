class_name GameCharacter
extends CharacterBody2D

@export var speed: float
var direction := Vector2.ZERO

@onready var sprite:Sprite2D = $Sprite2D


func _physics_process(_delta: float) -> void:
	move_and_slide()
