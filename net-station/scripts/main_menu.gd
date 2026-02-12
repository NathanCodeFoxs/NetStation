extends Control

func _ready():
	# Connect button signals to functions
	$ButtonContainer/StartButton.pressed.connect(_on_start_pressed)
	$ButtonContainer/ExitButton.pressed.connect(_on_exit_pressed)

func _on_start_pressed():
	# Go to level select screen
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_exit_pressed():
	# Quit the game
	get_tree().quit()
