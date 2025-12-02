extends CanvasLayer

@onready var control: Control = $Control
@onready var lines: Control = $Control/SkillTree/Lines
@onready var nodes: Control = $Control/SkillTree/Nodes
@onready var title_label: Label = $Control/TitleLabel
@onready var path_buttons: HBoxContainer = $Control/PathButtons
@onready var description_box: PanelContainer = $Control/DescriptionBox
@onready var description_label: Label = $Control/DescriptionBox/DescriptionLabel

# XP Label to show current XP (add this node to your scene or create it dynamically)
var xp_label: Label

# Dictionary to store node references
var skill_nodes: Dictionary = {}

# Current active path
var current_path: String = "flame"

# Player's current XP (you'll want to connect this to your actual player stats)
var player_xp: int = 500  # Starting XP for testing

# Track unlocked skills (saved per path)
var unlocked_skills: Dictionary = {
	"flame": [],  # Starting skills (roots) are unlocked by default
	"frost": [],
	"ferment": []
}

# Define skill trees for each path (now with xp_cost!)
var paths: Dictionary = {
	"flame": {
		"title": "Flame Path",
		"nodes": [
			{"id": "+10% Attack", "name": "Grilled Gumption", "pos": Vector2(200, 600), "xp_cost": 100, "description": "Permanently increase your attack damage by 10%."},
			{"id": "fire_trail", "name": "Torched and Tender", "pos": Vector2(200, 200), "xp_cost": 100, "description": "For 3 seconds, your main attack leaves a fiery trail that burns enemies. (burn lasts 2 seconds)"},
			{"id": "trail_upgrade", "name": "Broiled Brutality", "pos": Vector2(500, 125), "xp_cost": 150, "description": " 'Torched and Tender' is increased to 5 seconds and has double burn damage"},
			{"id": "status1", "name": "Carmelized Cruelty", "pos": Vector2(700, 150), "xp_cost": 200, "description": "Crit chance and Crit damage increased by 20% if enemy is burned"},
			{"id": "ability", "name": "Flaming Finger", "pos": Vector2(375, 250), "xp_cost": 250, "description": "Flambé enemies with your blowtorch!"},
			{"id": "ability_upgrade", "name": "Flambéed Fury", "pos": Vector2(350, 475), "xp_cost": 300, "description": "Your blowtorch range and damage are increased and flambé in all 4 directions."},
			{"id": "status2", "name": "Searing Indignation", "pos": Vector2(650, 375), "xp_cost": 200, "description": "Every consecutive attack on an enemy increases CRIT DMG, CRIT chance, and ATK by 1%. (Slash window resets after 0.5 seconds)"}
		],
		"connections": [
			["fire_trail", "+10% Attack"],
			["fire_trail", "trail_upgrade"],
			["fire_trail", "ability"],
			["trail_upgrade", "status1"],
			["ability", "ability_upgrade"],
			["ability", "status2"]
		]
	},
	"frost": {
		"title": "Frost Path",
		"nodes": [
			{"id": "+10% Movement Speed", "name": "Glacial Glide", "pos": Vector2(200, 600), "xp_cost": 100, "description": "Permanently increase your movement speed by 10%."},
			{"id": "trail", "name": "Crystallized Cascade ", "pos": Vector2(200, 200), "xp_cost": 100, "description": "For 3 seconds, your main attack leaves a trail of ice that freezes enemies for 0.5 seconds every 1 second"},
			{"id": "trail_upgrade", "name": "Permafrost Promenade", "pos": Vector2(500, 125), "xp_cost": 150, "description": "Your frost trail now freezes for 1 second every second and its duration is increased to 5 seconds."},
			{"id": "status1", "name": "Frostbite Fracture", "pos": Vector2(700, 150), "xp_cost": 200, "description": "Emit a frozen shockwave every 5 seconds that freezes enemies for 1 second"},
			{"id": "ability", "name": "Frame Freeze", "pos": Vector2(375, 250), "xp_cost": 250, "description": "Freeze all enemies on screen for 2 seconds. (Projectiles can still move)"},
			{"id": "ability_upgrade", "name": "Nitrogen Nirvana", "pos": Vector2(350, 475), "xp_cost": 300, "description": "After you activate Frame Freeze, double movement speed, and gain unlimited range. (Freeze Frame duration increased to 3 seconds)"},
			{"id": "status2", "name": "Refrigerated Reflexes", "pos": Vector2(650, 375), "xp_cost": 200, "description": "Your main attack now slows enemies for 2 seconds"}
		],
		"connections": [
			["trail", "+10% Movement Speed"],
			["trail", "trail_upgrade"],
			["trail", "ability"],
			["trail_upgrade", "status1"],
			["ability", "ability_upgrade"],
			["ability", "status2"]
		]
	},
	"ferment": {
		"title": "Fermented Path",
		"nodes": [
			{"id": "+10% Health", "name": "Ripened resilience", "pos": Vector2(200, 600), "xp_cost": 100, "description": "Permanently increase your maximum health by 10%."},
			{"id": "trail", "name": "Leeching Loam", "pos": Vector2(200, 200), "xp_cost": 100, "description": "For 3 seconds, your main attack leaves a trail of fertilizer that lifesteals from fruits."},
			{"id": "trail_upgrade", "name": "Vitamin Vamparism", "pos": Vector2(500, 125), "xp_cost": 150, "description": "Increase fermented trail duration to 5 seconds and siphon 10% ATK from each fruit that touches your fermented trail (Only applies once per trail activation)"},
			{"id": "status1", "name": "Overripe Outrage", "pos": Vector2(700, 150), "xp_cost": 200, "description": "Deal extra % based damage depending on your health. (Full health multiplier is 100% of base attack)"},
			{"id": "ability", "name": "Fertilized Farm", "pos": Vector2(375, 250), "xp_cost": 250, "description": "For 5 seconds every fruit you kill revives as an ally fruit at full health. Ally fruits attack enemy fruit for 10 seconds before fully decaying."},
			{"id": "ability_upgrade", "name": "Vineyard Vengeance", "pos": Vector2(350, 475), "xp_cost": 300, "description": "All ally fruits have their base stats doubled."},
			{"id": "status2", "name": "Hard to Peel", "pos": Vector2(650, 375), "xp_cost": 200, "description": "Gain a recharging shield that nullifies the first hit from an enemy.(Shield Recharges every 10 seconds)"}
		],
		"connections": [
			["trail", "+10% Health"],
			["trail", "trail_upgrade"],
			["trail", "ability"],
			["trail_upgrade", "status1"],
			["ability", "ability_upgrade"],
			["ability", "status2"]
		]
	}
}

# Store skill data for quick lookup
var skill_data: Dictionary = {}

# Style resources for different button states
var style_locked: StyleBoxFlat
var style_unlocked: StyleBoxFlat
var style_purchasable: StyleBoxFlat


func _ready() -> void:
	add_to_group("skill_tree_menu")
	control.visible = false
	description_box.visible = false

	# Move title to the right
	title_label.position.x = 450
	
	# Create styles for buttons
	_create_button_styles()
	
	# Create XP label
	_create_xp_label()
	
	_setup_path_buttons()
	_load_path(current_path)


func _create_button_styles() -> void:
	# Locked style (dark, greyed out)
	style_locked = StyleBoxFlat.new()
	style_locked.bg_color = Color(0.2, 0.2, 0.2, 0.9)  # Dark grey
	style_locked.border_color = Color(0.3, 0.3, 0.3)
	style_locked.set_border_width_all(2)
	style_locked.set_corner_radius_all(8)
	
	# Unlocked style (green tint)
	style_unlocked = StyleBoxFlat.new()
	style_unlocked.bg_color = Color(0.1, 0.4, 0.1, 0.9)  # Dark green
	style_unlocked.border_color = Color(0.2, 0.8, 0.2)  # Bright green border
	style_unlocked.set_border_width_all(3)
	style_unlocked.set_corner_radius_all(8)
	
	# Purchasable style (can afford, connected to unlocked)
	style_purchasable = StyleBoxFlat.new()
	style_purchasable.bg_color = Color(0.3, 0.3, 0.5, 0.9)  # Blue-ish
	style_purchasable.border_color = Color(0.4, 0.6, 1.0)  # Light blue border
	style_purchasable.set_border_width_all(2)
	style_purchasable.set_corner_radius_all(8)


func _create_xp_label() -> void:
	xp_label = Label.new()
	xp_label.text = "XP: " + str(player_xp)
	xp_label.position = Vector2(900, 20)  # Top right area
	xp_label.add_theme_font_size_override("font_size", 24)
	control.add_child(xp_label)


func _setup_path_buttons() -> void:
	for child in path_buttons.get_children():
		child.queue_free()
	
	for path_id in paths.keys():
		var btn := Button.new()
		btn.text = paths[path_id]["title"]
		btn.custom_minimum_size = Vector2(120, 40)
		btn.pressed.connect(_on_path_selected.bind(path_id))
		path_buttons.add_child(btn)


func _load_path(path_id: String) -> void:
	current_path = path_id
	title_label.text = paths[path_id]["title"]
	
	# Clear existing skill nodes
	for child in nodes.get_children():
		child.queue_free()
	skill_nodes.clear()
	skill_data.clear()
	
	# Create nodes for this path
	for node_data in paths[path_id]["nodes"]:
		_create_skill_node(node_data)
	
	# Update button styles based on unlock status
	_update_all_button_styles()
	
	lines.queue_redraw()
	description_box.visible = false


func _create_skill_node(data: Dictionary) -> void:
	var id = data["id"]
	var display_name = data["name"]
	var pos = data["pos"]
	var xp_cost = data["xp_cost"]
	var description = data["description"]
	
	# Create a container for the button and cost label
	var container = Control.new()
	container.position = pos - Vector2(50, 50)
	container.custom_minimum_size = Vector2(100, 100)
	
	# Create the main button
	var btn = Button.new()
	btn.text = display_name
	btn.custom_minimum_size = Vector2(100, 80)
	btn.position = Vector2(0, 0)
	btn.pressed.connect(_on_skill_selected.bind(id))
	btn.mouse_entered.connect(_on_skill_hover.bind(id))
	btn.mouse_exited.connect(_on_skill_hover_end)
	
	# Center the text
	btn.add_theme_constant_override("align", 1)
	
	container.add_child(btn)
	
	# Create XP cost label (bottom right of button)
	var cost_label = Label.new()
	if xp_cost > 0:
		cost_label.text = str(xp_cost) + " XP"

	cost_label.position = Vector2(5, 60)
	container.add_child(cost_label)
	
	nodes.add_child(container)
	
	# Store references
	skill_nodes[id] = btn
	skill_data[id] = {
		"xp_cost": xp_cost,
		"description": description,
		"container": container,
		"cost_label": cost_label
	}


func _update_all_button_styles() -> void:
	for skill_id in skill_nodes.keys():
		_update_button_style(skill_id)


func _update_button_style(skill_id: String) -> void:
	var btn = skill_nodes[skill_id]
	var data = skill_data[skill_id]
	var is_unlocked = is_skill_unlocked(skill_id)
	var can_purchase = can_purchase_skill(skill_id)
	
	if is_unlocked:
		btn.add_theme_stylebox_override("normal", style_unlocked)
		btn.add_theme_stylebox_override("hover", style_unlocked)
		btn.add_theme_stylebox_override("pressed", style_unlocked)
		data["cost_label"].text = "OWNED"
		data["cost_label"].add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
	elif can_purchase:
		btn.add_theme_stylebox_override("normal", style_purchasable)
		btn.add_theme_stylebox_override("hover", style_purchasable)
		btn.add_theme_stylebox_override("pressed", style_purchasable)
		data["cost_label"].add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	else:
		btn.add_theme_stylebox_override("normal", style_locked)
		btn.add_theme_stylebox_override("hover", style_locked)
		btn.add_theme_stylebox_override("pressed", style_locked)
		data["cost_label"].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))


func is_skill_unlocked(skill_id: String) -> bool:
	if not unlocked_skills.has(current_path):
		return false
	return skill_id in unlocked_skills[current_path]


func can_purchase_skill(skill_id: String) -> bool:
	# Already unlocked
	if is_skill_unlocked(skill_id):
		return false
	
	# Define root skills that can be purchased without connections
	var root_skills = ["+10% Attack", "+10% Movement Speed", "+10% Health"]
	
	# If nothing is unlocked yet, only allow root skills
	if unlocked_skills[current_path].is_empty():
		if skill_id not in root_skills:
			return false
		# Check if player has enough XP
		var cost = skill_data[skill_id]["xp_cost"]
		return player_xp >= cost
	
	# Check if connected to an unlocked skill
	var has_unlocked_connection = false
	var connections = paths[current_path]["connections"]
	
	for connection in connections:
		if connection[1] == skill_id and is_skill_unlocked(connection[0]):
			has_unlocked_connection = true
			break
		if connection[0] == skill_id and is_skill_unlocked(connection[1]):
			has_unlocked_connection = true
			break
	
	if not has_unlocked_connection:
		return false
	
	# Check if player has enough XP
	var cost = skill_data[skill_id]["xp_cost"]
	return player_xp >= cost


func purchase_skill(skill_id: String) -> bool:
	if not can_purchase_skill(skill_id):
		return false
	
	var cost = skill_data[skill_id]["xp_cost"]
	
	# Deduct XP
	player_xp -= cost
	xp_label.text = "XP: " + str(player_xp)
	
	# Add to unlocked skills
	if not unlocked_skills.has(current_path):
		unlocked_skills[current_path] = []
	unlocked_skills[current_path].append(skill_id)
	
	# Apply the skill effect (you'll customize this)
	_apply_skill_effect(skill_id)
	
	# Update all button styles
	_update_all_button_styles()
	
	print("Purchased skill: ", skill_id, " for ", cost, " XP")
	return true


func _apply_skill_effect(skill_id: String) -> void:
	# This is where you apply the actual skill effects to the player
	# You'll want to connect this to your player stats system
	match skill_id:
		"+10% Attack":
			print("Applying +10% Attack boost!")
			# Example: SignalBus.emit_signal("stat_boost", "attack", 0.10)
		"+10% Movement Speed":
			print("Applying +10% Movement Speed boost!")
		"+10% Health":
			print("Applying +10% Health boost!")
		"fire_trail", "trail":
			print("Trail ability unlocked!")
		"trail_upgrade":
			print("Trail upgraded!")
		"ability":
			print("New ability unlocked!")
		"ability_upgrade":
			print("Ability upgraded!")
		"status1", "status2":
			print("Status effect unlocked!")
		_:
			print("Skill effect not implemented: ", skill_id)


func _on_skill_hover(skill_id: String) -> void:
	if skill_data.has(skill_id):
		var data = skill_data[skill_id]
		var desc = data["description"]
		var cost = data["xp_cost"]
		var is_unlocked = is_skill_unlocked(skill_id)
		
		if is_unlocked:
			description_label.text = desc + "\n\n[OWNED]"
		elif can_purchase_skill(skill_id):
			description_label.text = desc + "\n\nCost: " + str(cost) + " XP\n[Click to purchase]"
		else:
			description_label.text = desc + "\n\nCost: " + str(cost) + " XP\n[Locked - unlock connected skill first]"
		
		description_box.visible = true
		
	# Prevents descrption box from going over the edge
	var viewport_size = get_viewport().get_visible_rect().size
	description_box.position = Vector2(
		viewport_size.x - description_box.size.x - 20, 
		viewport_size.y - description_box.size.y - 20
		)


func _on_skill_hover_end() -> void:
	description_box.visible = false


func show_menu() -> void:
	control.visible = true
	get_tree().paused = true
	xp_label.text = "XP: " + str(player_xp)
	_update_all_button_styles()
	lines.queue_redraw()


func hide_menu() -> void:
	control.visible = false
	get_tree().paused = false


func _on_path_selected(path_id: String) -> void:
	_load_path(path_id)


func _on_skill_selected(skill_id: String) -> void:
	print("Clicked skill: ", skill_id)
	
	if is_skill_unlocked(skill_id):
		print("Already unlocked!")
		return
	
	if can_purchase_skill(skill_id):
		purchase_skill(skill_id)
	else:
		print("Cannot purchase - either locked or not enough XP")


func _unhandled_input(event: InputEvent) -> void:
	if control.visible and event.is_action_pressed("escape_menu"):
		hide_menu()


func get_connections() -> Array:
	return paths[current_path]["connections"]


func get_skill_nodes() -> Dictionary:
	return skill_nodes


# Call this from your game when player collects XP
func add_xp(amount: int) -> void:
	player_xp += amount
	if xp_label:
		xp_label.text = "XP: " + str(player_xp)
