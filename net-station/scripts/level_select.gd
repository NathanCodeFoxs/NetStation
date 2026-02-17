extends Control

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
	var level_buttons = [
		$LevelGrid/Level1Button,
		$LevelGrid/Level2Button,
		$LevelGrid/Level3Button,
		$LevelGrid/Level4Button,
		$LevelGrid/Level5Button
	]
	
	for i in range(level_buttons.size()):
		var level_num = i + 1
		var button = level_buttons[i]
		
		if level_num > unlocked_levels:
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5, 0.7)
			if button.has_node("LockedLabel"):
				button.get_node("LockedLabel").visible = true
		else:
			button.disabled = false
			button.modulate = Color(1, 1, 1, 1)
			if button.has_node("LockedLabel"):
				button.get_node("LockedLabel").visible = false

func _on_level_pressed(level_number: int):
	print("Loading Level ", level_number)
	
	# FIX: Added level 4 & 5 with safety check
	var scene_path = "res://scenes/levels/level_%d.tscn" % level_number
	
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		print("Level %d scene not created yet!" % level_number)
		# TODO: Show "Coming Soon" popup instead of crashing

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
