class_name PlayerInputComponent
extends InputComponent

func update(event: InputEvent) -> void:
	_parent.direction = Vector2(
		int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
		int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	).normalized()
	
	var slice = _parent.get_node("Slice")
	var mouse_pos = _parent.get_global_mouse_position()
	
	if Input.is_action_just_pressed("special_1") and slice.current_element < 0:
		if slice.can_use_element(1):
			slice.set_element(1)
		else:
			print("Flame trail not unlocked yet!")
		
	elif Input.is_action_just_pressed("special_2") and slice.current_element < 0:
		if slice.can_use_element(2):
			slice.set_element(2)
		else:
			print("Frost trail not unlocked yet!")
		
	elif Input.is_action_just_pressed("special_3") and slice.current_element < 0:
		if slice.can_use_element(3):
			slice.set_element(3)
		else:
			print("Ferment trail not unlocked yet!")
		
	elif Input.is_action_just_pressed("special_4"):
		if _parent.active_abilities["flame_flinger"]["enabled"]:
			var flame_flinger = _parent.get_node_or_null("FlameFlingerArea")
			if flame_flinger:
				flame_flinger.toggle()
		else:
			print("Flame Flinger ability not unlocked yet!")
			
	elif Input.is_action_just_pressed("special_5"):
		if _parent.active_abilities["freeze_frame"]["enabled"]:
			_activate_freeze_frame()
		else:
			print("Freeze Frame ability not unlocked yet!")
	
	elif Input.is_action_just_pressed("special_6"):
		if _parent.active_abilities["fertilized_farm"]["enabled"]:
			_activate_fertilized_farm()
		else:
			print("Fertilized Farm ability not unlocked yet!")
	
	if Input.is_action_pressed("left_click") and _parent.global_position.distance_to(mouse_pos) < _parent.slice_radius:
		slice.clear_points()
		if slice.element_ready >= 0 and slice.current_element < 0:
			slice.start_trail(slice.element_ready)
		
		if event is InputEventMouseMotion and event.relative.length() > 1:
			_parent.is_slicing = true
			_parent.vel_vec = event.relative
			_parent.curr_vel = abs(Vector2.ZERO.distance_to(_parent.vel_vec))
			
			slice.slicing(mouse_pos)
		else:
			_parent.is_slicing = false
			slice.clear_points()
	else:
		_parent.is_slicing = false
		slice.clear_points()
		
		if slice.current_element >= 0:
			slice.end_trail()

func _activate_freeze_frame() -> void:
	var params = _parent.active_abilities["freeze_frame"]["params"]
	var duration = params.get("duration", 4.0)
	var speed_mult = params.get("speed_multiplier", 1.0)
	var _unlimited_range = params.get("unlimited_range", false)
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy is Fruit:
			enemy.stunned = true
	
	if speed_mult > 1.0:
		_parent.base_speed *= speed_mult
	
	var freeze_timer = Timer.new()
	freeze_timer.wait_time = duration
	freeze_timer.one_shot = true
	_parent.add_child(freeze_timer)
	
	freeze_timer.timeout.connect(
		func():
			for enemy in get_tree().get_nodes_in_group("enemies"):
				if enemy is Fruit:
					enemy.stunned = false
			
			if speed_mult > 1.0:
				_parent.base_speed /= speed_mult
			
			freeze_timer.queue_free()
	)
	freeze_timer.start()

func _activate_fertilized_farm() -> void:
	var params = _parent.active_abilities["fertilized_farm"]["params"]
	var spawn_duration = params.get("spawn_duration", 5.0)
	var ally_lifetime = params.get("ally_lifetime", 10.0)
	var stat_boost = _parent.fertilize_farm_mult if _parent.fertilize_farm_boost else 1.0
	
	
	_parent.fertilized_farm_active = true
	_parent.set_meta("fertilizer_farm_lifetime", ally_lifetime)
	_parent.set_meta("fertilizer_farm_stat_boost", stat_boost)
	
	var farm_timer = Timer.new()
	farm_timer.wait_time = spawn_duration
	farm_timer.one_shot = true
	_parent.add_child(farm_timer)
	
	farm_timer.timeout.connect(
		func():
			_parent.fertilized_farm_active = false
			_parent.remove_meta("fertilizer_farm_lifetime")
			_parent.remove_meta("fertilizer_farm_stat_boost")
			farm_timer.queue_free()
	)
	farm_timer.start()
