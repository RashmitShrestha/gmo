class_name BananaReactiveComponent
extends ReactiveComponent

@export var detection_area: Area2D

func _ready():
	super()
	
	_parent.mouse_entered.connect(_on_mouse_entered)
	_parent.mouse_exited.connect(_on_mouse_exited)
	
	detection_area.body_entered.connect(
		func(body: Node2D):
			if body == _parent.peach_tree and _parent.peach_tree and _parent.peach_tree.is_dead:
				return

			if (_parent.position - body.position).distance_squared_to(\
				_parent.position - _parent.target.position):
				_parent.target = body
	)


func update():
	if null == _parent.target:
		if _parent.peach_tree and not _parent.peach_tree.is_dead:
			_parent.target = _parent.peach_tree
		else:
			_parent.target = _parent.warden

	_parent.direction = (_parent.target.global_position - _parent.global_position).normalized()
	
	if _parent.get_slide_collision_count():
		_parent.stunned = true


func _on_mouse_entered():
	print("entered banana")


func _on_mouse_exited():
	print("exited banana")
