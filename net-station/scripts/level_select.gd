extends Control

# Track which levels are unlocked (save/load this later)
var unlocked_levels = 1

func _ready():
	# Connect all level buttons
	$LevelGrid/Level1Button.pressed.connect(_on_level_pressed.bind(1))
	$LevelGrid/Level2Button.pressed.connect(_on_level_pressed.bind(2))
	$LevelGrid/Level3Button.pressed.connect(_on_level_pressed.bind(3))
	$LevelGrid/Level4Button.pressed.connect(_on_level_pressed.bind(4))
	$LevelGrid/Level5Button.pressed.connect(_on_level_pressed.bind(5))
	
	# Connect back button
	$BackButton.pressed.connect(_on_back_pressed)
	
	# Set up which levels are locked
	update_level_access()

func update_level_access():
	# Disable and gray out locked levels
	var level_buttons = [
		$LevelGrid/Level1Button,
		$LevelGrid/Level2Button,
		$LevelGrid/Level3Button,
		$LevelGrid/Level4Button,
		$LevelGrid/Level5Button,
		$LevelGrid/Level6Button
	]
	
	for i in range(level_buttons.size()):
		var level_num = i + 1
		var button = level_buttons[i]
		
		if level_num > unlocked_levels:
			# Lock this level
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5, 0.7)  # Gray out
			
			# Show lock label if it exists
			if button.has_node("LockedLabel"):
				button.get_node("LockedLabel").visible = true
		else:
			# Unlock this level
			button.disabled = false
			button.modulate = Color(1, 1, 1, 1)  # Normal color
			
			# Hide lock label if it exists
			if button.has_node("LockedLabel"):
				button.get_node("LockedLabel").visible = false

func _on_level_pressed(level_number: int):
	print("Loading Level ", level_number)
	
	# Load the appropriate level scene
	match level_number:
		1:
			get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
		2:
			get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")
		3:
			get_tree().change_scene_to_file("res://scenes/levels/level_3.tscn")
		# Add more as you create them

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
