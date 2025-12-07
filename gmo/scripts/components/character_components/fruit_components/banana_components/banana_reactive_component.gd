class_name BananaReactiveComponent
extends ReactiveComponent

@export var detection_area: Area2D

func _ready():
	super()
	
	_parent.mouse_entered.connect(_on_mouse_entered)
	_parent.mouse_exited.connect(_on_mouse_exited)
	
	detection_area.body_entered.connect(
		func(body: Node2D):
			if (_parent.position - body.position).distance_squared_to(\
				_parent.position - _parent.target.position):
				_parent.target = body
	)


func update():
	if null == _parent.target:
		_parent.target = _parent.peach_tree
	
	_parent.direction = (_parent.target.position - _parent.position).normalized()
	
	if _parent.get_slide_collision_count():
		_parent.stunned = true


func _on_mouse_entered():
	print("entered banana")


func _on_mouse_exited():
	print("exited banana")
