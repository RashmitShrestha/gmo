class_name PlayerInputComponent
extends InputComponent

# _parent refers to warden.gd
func update(event: InputEvent) -> void:
	_parent.direction = Vector2(
		int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
		int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	).normalized()
	
	var slice = _parent.get_node("Slice")
	var mouse_pos = _parent.get_global_mouse_position()
	
	# pressing the number keys 1, 2, or 3 will set the element (only if unlocked)
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
		# Check if blowtorch ability is unlocked
		if _parent.active_abilities["flame_flinger"]["enabled"]:
			var flame_flinger = _parent.get_node_or_null("FlameFlingerArea")
			if flame_flinger:
				flame_flinger.toggle()
		else:
			print("Flame Flinger ability not unlocked yet!")
			
	#elif Input.is_action_just_pressed("special_5"):
		## Check if freeze frame ability is unlocked
		#if _parent.active_abilities["freeze_frame"]["enabled"]:
			#_activate_freeze_frame()
		#else:
			#print("Freeze Frame ability not unlocked yet!")
	#
	#elif Input.is_action_just_pressed("special_6"):
		## Check if ally fruit spawn ability is unlocked
		#if _parent.active_abilities["fertilizer_farm"]["enabled"]:
			#_activate_fertilizer_farm()
		#else:
			#print("Fertilized Farm ability not unlocked yet!")
	
	# Handle slicing/drawing
	if Input.is_action_pressed("left_click") and _parent.global_position.distance_to(mouse_pos) < _parent.slice_radius:
		slice.clear_points()
		# If we have an element ready and haven't started slicing yet, activate it
		if slice.element_ready >= 0 and slice.current_element < 0:
			slice.start_trail(slice.element_ready)
		
		if event is InputEventMouseMotion and event.relative.length() > 1:
			# Update parent values
			_parent.is_slicing = true
			_parent.vel_vec = event.relative
			_parent.curr_vel = abs(Vector2.ZERO.distance_to(_parent.vel_vec))
			
			# Only add points to trail if element is active
			slice.slicing(mouse_pos)
		else:
			# Not moving, stop particles
			_parent.is_slicing = false
			slice.clear_points()
	else:
		# Mouse released
		_parent.is_slicing = false
		slice.clear_points()
		
		# if we were using an element, end the slice
		if slice.current_element >= 0:
			slice.end_trail()

func _activate_freeze_frame() -> void:
	var params = _parent.active_abilities["freeze_frame"]["params"]
	var duration = params.get("duration", 4.0)
	var speed_mult = params.get("speed_multiplier", 1.0)
	var _unlimited_range = params.get("unlimited_range", false)
	
	print("Activating Freeze Frame for ", duration, "s!")
	
	# Freeze all enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy is Fruit:
			enemy.stunned = true
	
	# Apply speed boost if upgraded
	if speed_mult > 1.0:
		_parent.base_speed *= speed_mult
	
	# Set up timer to unfreeze
	var freeze_timer = Timer.new()
	freeze_timer.wait_time = duration
	freeze_timer.one_shot = true
	_parent.add_child(freeze_timer)
	
	freeze_timer.timeout.connect(
		func():
			# Unfreeze enemies
			for enemy in get_tree().get_nodes_in_group("enemies"):
				if enemy is Fruit:
					enemy.stunned = false
			
			# Remove speed boost
			if speed_mult > 1.0:
				_parent.base_speed /= speed_mult
			
			freeze_timer.queue_free()
			print("Freeze Frame ended!")
	)
	freeze_timer.start()

func _activate_fertilizer_farm() -> void:
	var params = _parent.active_abilities["ally_fruit_spawn"]["params"]
	var spawn_duration = params.get("spawn_duration", 5.0)
	var ally_lifetime = params.get("ally_lifetime", 10.0)
	
	print("Activating Fertilized Farm for ", spawn_duration, "s!")
	
	# This would need to be implemented in your fruit spawning/death system
	# Set a flag that enemies killed during this time spawn as allies
	SignalBus.emit_signal("status_effect_applied", "game", "ally_fruit_spawn_active", {
		"duration": spawn_duration,
		"ally_lifetime": ally_lifetime,
		"stat_boost": _parent.ally_stat_boost_multiplier if _parent.ally_stat_boost_active else 1.0
	})
