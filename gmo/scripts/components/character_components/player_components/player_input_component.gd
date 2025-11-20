class_name PlayerInputComponent
extends InputComponent


func update(event: InputEvent) -> void:
	_parent.direction = Vector2(
		int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
		int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	).normalized()
	
	'''
	if Input.is_action_pressed("left_click"):
		if event is InputEventMouseMotion:
			character.is_slicing = true
			character.vel_vec = event.relative
			character.curr_vel = abs(Vector2.ZERO.distance_to(character.vel_vec))
			
			# tweak to find the best number for "full velocity hits" 
			#if curr_vel > 25:
				#print("F") # fast
			#elif curr_vel > 7.5:
				#print("M") # medium
			#else: 
				#print("S") # slow
			
			%Slice.slicing()
	else:
		character.is_slicing = false
		%Slice.clear_points()
		%Slice.points_queue = []
	'''
