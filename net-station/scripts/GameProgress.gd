extends Node

# Simple save system for tracking level progress
# This will be an AutoLoad singleton

const SAVE_FILE = "user://netstation_progress.save"

var unlocked_levels: int = 1
var level_scores: Dictionary = {}

func _ready() -> void:
	load_progress()

# Save progress to file
func save_progress() -> void:
	var save_data = {
		"unlocked_levels": unlocked_levels,
		"level_scores": level_scores
	}
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Progress saved: %d levels unlocked" % unlocked_levels)

# Load progress from file
func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		print("No save file found, starting fresh")
		return
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		
		if save_data is Dictionary:
			unlocked_levels = save_data.get("unlocked_levels", 1)
			level_scores = save_data.get("level_scores", {})
			print("Progress loaded: %d levels unlocked" % unlocked_levels)

# Unlock next level
func unlock_level(level_number: int) -> void:
	if level_number > unlocked_levels:
		unlocked_levels = level_number
		save_progress()
		print("Level %d unlocked!" % level_number)

# Check if level is unlocked
func is_level_unlocked(level_number: int) -> bool:
	return level_number <= unlocked_levels

# Complete a level with score
func complete_level(level_number: int, score: int, total: int) -> void:
	level_scores[level_number] = {"score": score, "total": total}
	
	# Unlock next level
	unlock_level(level_number + 1)

# Reset all progress (for testing)
func reset_progress() -> void:
	unlocked_levels = 1
	level_scores = {}
	save_progress()
	print("Progress reset!")
