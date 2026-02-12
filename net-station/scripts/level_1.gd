extends Control

# ========================================
# LEVEL DATA - CUSTOMIZE FOR EACH LEVEL
# ========================================

var level_title = "Introduction to Networks"

var slides = [
	"What is a network?\n\nA network is a group of computers and devices that are connected together. Think of it like a team where all members can talk to each other and share things.",
	
	"Why do we need networks?\n\nWe use networks so that computers and devices can share files, access the internet, send messages, and use resources like printers. It makes working and sharing much easier!",
	
	"Example:\n\nImagine you're in your school's computer lab. There are many computers and a printer. Instead of each computer having its own printer, all the computers are connected to a single printer through a network.\n\nWhen you print your homework, your computer sends the print job over the network to the shared printer. This way, everyone in the lab can share the printer easily without needing a separate printer for each computer."
]

var quiz = [
	{
		"question": "Based on the previous slides, what is the main purpose of a network?",
		"answers": [
			"To make computers faster",
			"To connect devices so they can share information and resources",
			"To turn off devices automatically"
		],
		"correct": 1  # Index of correct answer (0=A, 1=B, 2=C)
	},
	{
		"question": "Which of these is a common resource shared over a network?",
		"answers": [
			"A game console",
			"A printer",
			"A TV"
		],
		"correct": 1
	},
	{
		"question": "If you send an email to your friend, what is likely happening?",
		"answers": [
			"Your computer is playing a game",
			"Your computer is sending information over the network to your friend's email server",
			"Your computer is turning off"
		],
		"correct": 1
	}
]

# ========================================
# SCRIPT LOGIC - REUSABLE FOR ALL LEVELS
# ========================================

var current_step = 0
var total_steps = 0
var quiz_score = 0
var in_quiz_mode = false

# Node references
@onready var modal_overlay = $ModalOverlay
@onready var popup_panel = $PopupPanel
@onready var popup_title = $PopupPanel/PopupMargin/PopupContent/PopupTitle
@onready var content_text = $PopupPanel/PopupMargin/PopupContent/ContentText
@onready var progress_label = $PopupPanel/PopupMargin/PopupContent/ProgressLabel
@onready var answer_buttons_container = $PopupPanel/PopupMargin/PopupContent/AnswerButtons
@onready var answer_a = $PopupPanel/PopupMargin/PopupContent/AnswerButtons/AnswerA
@onready var answer_b = $PopupPanel/PopupMargin/PopupContent/AnswerButtons/AnswerB
@onready var answer_c = $PopupPanel/PopupMargin/PopupContent/AnswerButtons/AnswerC
@onready var nav_buttons = $PopupPanel/PopupMargin/PopupContent/NavButtons
@onready var prev_button = $PopupPanel/PopupMargin/PopupContent/NavButtons/PrevButton
@onready var next_button = $PopupPanel/PopupMargin/PopupContent/NavButtons/NextButton
@onready var feedback_label = $PopupPanel/PopupMargin/PopupContent/FeedbackLabel
@onready var close_button = $PopupPanel/TopRightAnchor/CloseButton
@onready var train_icon = $ProgressBarContainer/TrainIcon

func _ready():
	total_steps = slides.size() + quiz.size()
	
	# Connect buttons
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	close_button.pressed.connect(_on_close_pressed)
	answer_a.pressed.connect(_on_answer_selected.bind(0))
	answer_b.pressed.connect(_on_answer_selected.bind(1))
	answer_c.pressed.connect(_on_answer_selected.bind(2))
	
	# Start with popup hidden
	modal_overlay.visible = false
	popup_panel.visible = false
	
	# Auto-show first slide after 0.5 seconds
	await get_tree().create_timer(0.5).timeout
	show_popup()
	load_slide(0)

func show_popup():
	modal_overlay.visible = true
	popup_panel.visible = true
	
	# Animate popup appearing
	popup_panel.scale = Vector2(0.8, 0.8)
	popup_panel.modulate.a = 0
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup_panel, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(popup_panel, "modulate:a", 1.0, 0.3)

func hide_popup():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup_panel, "scale", Vector2(0.8, 0.8), 0.2)
	tween.tween_property(popup_panel, "modulate:a", 0.0, 0.2)
	
	await tween.finished
	modal_overlay.visible = false
	popup_panel.visible = false

func load_slide(index: int):
	in_quiz_mode = false
	popup_title.text = level_title
	content_text.text = slides[index]
	progress_label.text = "Slide %d / %d" % [index + 1, slides.size()]
	
	# Show text, hide quiz elements
	content_text.visible = true
	answer_buttons_container.visible = false
	feedback_label.visible = false
	nav_buttons.visible = true
	
	# Update buttons
	prev_button.disabled = (index == 0)
	
	if index == slides.size() - 1:
		next_button.text = "Start Quiz →"
	else:
		next_button.text = "Next →"
	
	update_train_position()

func load_quiz_question(index: int):
	in_quiz_mode = true
	var q = quiz[index]
	
	popup_title.text = "Quiz Time! 🎓"
	content_text.text = q["question"]
	progress_label.text = "Question %d / %d" % [index + 1, quiz.size()]
	
	# Show quiz elements, hide slide nav
	content_text.visible = true
	answer_buttons_container.visible = true
	feedback_label.visible = false
	nav_buttons.visible = false
	
	# Set answers
	answer_a.text = "A) " + q["answers"][0]
	answer_b.text = "B) " + q["answers"][1]
	answer_c.text = "C) " + q["answers"][2]
	
	# Reset button states
	var buttons = [answer_a, answer_b, answer_c]
	for btn in buttons:
		btn.disabled = false
		btn.modulate = Color(1, 1, 1)

func _on_prev_pressed():
	if current_step > 0:
		current_step -= 1
		load_slide(current_step)

func _on_next_pressed():
	if current_step < slides.size() - 1:
		# Next slide
		current_step += 1
		load_slide(current_step)
	else:
		# Start quiz
		current_step = slides.size()
		load_quiz_question(0)

func _on_answer_selected(answer_index: int):
	var question_index = current_step - slides.size()
	var q = quiz[question_index]
	
	# Disable all buttons
	var buttons = [answer_a, answer_b, answer_c]
	for btn in buttons:
		btn.disabled = true
	
	feedback_label.visible = true
	
	if answer_index == q["correct"]:
		# Correct answer
		quiz_score += 1
		feedback_label.text = "✓ Correct!"
		feedback_label.add_theme_color_override("font_color", Color.GREEN)
		buttons[answer_index].modulate = Color(0.5, 1, 0.5)
	else:
		# Wrong answer
		feedback_label.text = "✗ Incorrect. The correct answer was: " + ["A", "B", "C"][q["correct"]]
		feedback_label.add_theme_color_override("font_color", Color.RED)
		buttons[answer_index].modulate = Color(1, 0.5, 0.5)
		buttons[q["correct"]].modulate = Color(0.5, 1, 0.5)
	
	# Move train
	update_train_position()
	
	# Wait then show next question or finish
	await get_tree().create_timer(2.0).timeout
	
	if question_index < quiz.size() - 1:
		current_step += 1
		load_quiz_question(question_index + 1)
	else:
		finish_level()

func finish_level():
	var percentage = (float(quiz_score) / quiz.size()) * 100
	
	popup_title.text = "Level Complete! 🎉"
	content_text.text = "Congratulations!\n\nYou scored %d out of %d (%.0f%%)\n\nYou've learned the basics of computer networks!" % [quiz_score, quiz.size(), percentage]
	progress_label.text = ""
	
	answer_buttons_container.visible = false
	feedback_label.visible = false
	nav_buttons.visible = true
	
	prev_button.visible = false
	next_button.text = "Back to Levels"
	next_button.disabled = false
	next_button.pressed.disconnect(_on_next_pressed)
	next_button.pressed.connect(_on_finish_pressed)

func _on_finish_pressed():
	# TODO: Save that Level 1 is complete, unlock Level 2
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_close_pressed():
	# Return to level select
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func update_train_position():
	# Calculate train position based on progress
	var progress = float(current_step + 1) / total_steps
	
	# Train travels from X: 90 to X: 1150
	var start_x = 90
	var end_x = 1150
	var target_x = start_x + (progress * (end_x - start_x))
	
	# Animate train
	var tween = create_tween()
	tween.tween_property(train_icon, "position:x", target_x, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
