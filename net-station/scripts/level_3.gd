extends Control

# ========================================
# LEVEL DATA - Basic Network Devices
# ========================================

var level_title = "Basic Network Devices"

var slides = [
	"Basic Network Devices\n\nRouter, Switch, Modem, Access Point, and Network Cable are the most commonly known network devices. These devices can connect to each other through wired or wireless connections.",
	
	"Layer 1 Devices - Physical Layer:\n\n• Hub: A central connection point for devices in a LAN.\n\n• Repeater: Regenerates signals to extend the range of a network.\n\n• Modem: Connects your home network to the internet.",
	
	"Layer 2 Devices - Data Link Layer:\n\n• Switch: Connects devices within a LAN.\n\n• Bridge: Connects two separate LAN segments to make them appear as one.\n\n• Access Point: Extends Wi-Fi coverage.",
	
	"Layer 3 Devices - Network Layer:\n\n• Router: Connects different networks and directs data.\n\n• Brouter (Bridge Router): A hybrid device that acts as both a Bridge and a Router.",
	
	"Layer 4-7 Devices - Advanced Processing:\n\n• Gateway: A translator between two dissimilar networks.\n\n• Firewall: Security guard. Controls incoming and outgoing traffic based on security rules."
]

var quiz = [
	{
		"question": "Which device broadcasts data to all ports regardless of the destination?",
		"answers": [
			"Hub",
			"Router",
			"Switch",
			"Bridge"
		],
		"correct": 0  # A = Hub
	},
	{
		"question": "Which device converts digital signals to analog and vice versa for internet connection over telephone or cable lines?",
		"answers": [
			"Router",
			"Switch",
			"Modem",
			"Access Point"
		],
		"correct": 2  # C = Modem
	},
	{
		"question": "Which device functions both as a bridge and a router?",
		"answers": [
			"Gateway",
			"Multilayer Switch",
			"Brouter",
			"Firewall"
		],
		"correct": 2  # C = Brouter
	},
	{
		"question": "Which of the following devices does NOT break/increase the broadcast domain?",
		"answers": [
			"Hub",
			"Switch",
			"Repeater",
			"Router"
		],
		"correct": 0  # A = Hub
	}
]

# ========================================
# SCRIPT LOGIC - REUSABLE FOR ALL LEVELS
# ========================================

var current_step: int = 0
var total_steps: int = 0
var quiz_score: int = 0
var in_quiz_mode: bool = false
var quiz_current_index: int = 0
var level_finished: bool = false

# Node references
@onready var modal_overlay: ColorRect = $ModalOverlay
@onready var popup_panel: PanelContainer = $PopupPanel
@onready var popup_title: Label = $PopupPanel/PopupMargin/PopupContent/PopupTitle
@onready var content_text: Label = $PopupPanel/PopupMargin/PopupContent/ContentText
@onready var progress_label: Label = $PopupPanel/PopupMargin/PopupContent/ProgressLabel
@onready var answer_buttons_container: VBoxContainer = $PopupPanel/PopupMargin/PopupContent/AnswerButtons
@onready var answer_a: Button = $PopupPanel/PopupMargin/PopupContent/AnswerButtons/AnswerA
@onready var answer_b: Button = $PopupPanel/PopupMargin/PopupContent/AnswerButtons/AnswerB
@onready var answer_c: Button = $PopupPanel/PopupMargin/PopupContent/AnswerButtons/AnswerC
@onready var answer_d: Button = $PopupPanel/PopupMargin/PopupContent/AnswerButtons/AnswerD
@onready var nav_buttons: HBoxContainer = $PopupPanel/PopupMargin/PopupContent/NavButtons
@onready var prev_button: Button = $PopupPanel/PopupMargin/PopupContent/NavButtons/PrevButton
@onready var next_button: Button = $PopupPanel/PopupMargin/PopupContent/NavButtons/NextButton
@onready var feedback_label: Label = $PopupPanel/PopupMargin/PopupContent/FeedbackLabel
@onready var close_button: Button = $PopupPanel/TopRightAnchor/CloseButton
@onready var train_icon: Label = $ProgressBarContainer/TrainIcon

func _ready() -> void:
	total_steps = slides.size() + quiz.size()

	# Connect all buttons
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	close_button.pressed.connect(_on_close_pressed)
	answer_a.pressed.connect(_on_answer_selected.bind(0))
	answer_b.pressed.connect(_on_answer_selected.bind(1))
	answer_c.pressed.connect(_on_answer_selected.bind(2))
	answer_d.pressed.connect(_on_answer_selected.bind(3))

	# Set train at START position
	train_icon.position.x = 90.0

	# Hide popup initially
	modal_overlay.visible = false
	popup_panel.visible = false

	# Show first slide after short delay
	await get_tree().create_timer(0.5).timeout
	show_popup()
	load_slide(0)

# ─── POPUP ANIMATION ───────────────────────────────────────

func show_popup() -> void:
	modal_overlay.visible = true
	popup_panel.visible = true
	popup_panel.scale = Vector2(0.85, 0.85)
	popup_panel.modulate.a = 0.0

	var tween = create_tween().set_parallel(true)
	tween.tween_property(popup_panel, "scale", Vector2(1.0, 1.0), 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(popup_panel, "modulate:a", 1.0, 0.25)

func hide_popup() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(popup_panel, "scale", Vector2(0.85, 0.85), 0.2)
	tween.tween_property(popup_panel, "modulate:a", 0.0, 0.2)
	await tween.finished
	modal_overlay.visible = false
	popup_panel.visible = false

# ─── SLIDE LOADING ─────────────────────────────────────────

func load_slide(index: int) -> void:
	in_quiz_mode = false

	popup_title.text = level_title
	content_text.text = slides[index]
	progress_label.text = "📖  Slide %d / %d" % [index + 1, slides.size()]

	# Show slide elements, hide quiz elements
	content_text.visible = true
	answer_buttons_container.visible = false
	feedback_label.visible = false
	nav_buttons.visible = true
	prev_button.visible = true
	next_button.visible = true
	next_button.disabled = false
	prev_button.disabled = (index == 0)

	next_button.text = "Start Quiz →" if index == slides.size() - 1 else "Next →"

# ─── QUIZ LOADING ──────────────────────────────────────────

func load_quiz_question(index: int) -> void:
	in_quiz_mode = true
	quiz_current_index = index
	var q: Dictionary = quiz[index]

	popup_title.text = "Quiz Time! 🎓"
	content_text.text = q["question"]
	progress_label.text = "❓  Question %d / %d" % [index + 1, quiz.size()]

	# Show quiz elements, hide nav buttons
	content_text.visible = true
	answer_buttons_container.visible = true
	feedback_label.visible = false
	nav_buttons.visible = false

	# Set answer text (4 options: A, B, C, D)
	answer_a.text = "A)  " + q["answers"][0]
	answer_b.text = "B)  " + q["answers"][1]
	answer_c.text = "C)  " + q["answers"][2]
	answer_d.text = "D)  " + q["answers"][3]

	# Reset all answer button states
	for btn in [answer_a, answer_b, answer_c, answer_d]:
		btn.disabled = false
		btn.modulate = Color(1, 1, 1)

# ─── NAVIGATION ────────────────────────────────────────────

func _on_prev_pressed() -> void:
	if current_step > 0:
		current_step -= 1
		load_slide(current_step)
		update_train_position(current_step)

func _on_next_pressed() -> void:
	if current_step < slides.size() - 1:
		current_step += 1
		load_slide(current_step)
		update_train_position(current_step)
	else:
		# Transition to quiz
		current_step = slides.size()
		update_train_position(current_step)
		load_quiz_question(0)

func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

# ─── QUIZ ANSWER HANDLING ──────────────────────────────────

func _on_answer_selected(answer_index: int) -> void:
	# Prevent double-answering
	if level_finished:
		return

	var q: Dictionary = quiz[quiz_current_index]

	# Disable all answer buttons immediately
	for btn in [answer_a, answer_b, answer_c, answer_d]:
		btn.disabled = true

	feedback_label.visible = true

	if answer_index == q["correct"]:
		quiz_score += 1
		feedback_label.text = "✓  Correct! Well done!"
		feedback_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
		[answer_a, answer_b, answer_c, answer_d][answer_index].modulate = Color(0.5, 1.0, 0.5)
	else:
		feedback_label.text = "✗  Incorrect — correct answer: %s" % ["A", "B", "C", "D"][q["correct"]]
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
		[answer_a, answer_b, answer_c, answer_d][answer_index].modulate = Color(1.0, 0.45, 0.45)
		[answer_a, answer_b, answer_c, answer_d][q["correct"]].modulate = Color(0.5, 1.0, 0.5)

	# Advance train
	update_train_position(current_step + 1)

	# Wait then load next question or finish
	await get_tree().create_timer(2.0).timeout

	if quiz_current_index < quiz.size() - 1:
		current_step += 1
		load_quiz_question(quiz_current_index + 1)
	else:
		finish_level()

# ─── LEVEL COMPLETE ────────────────────────────────────────

func finish_level() -> void:
	level_finished = true
	var percentage: float = (float(quiz_score) / float(quiz.size())) * 100.0

	# Train reaches the station
	update_train_position(total_steps)

	popup_title.text = "Level Complete! 🎉"
	content_text.text = "Congratulations!\n\nYou scored  %d / %d  (%.0f%%)\n\nYou've learned about basic network devices!" \
		% [quiz_score, quiz.size(), percentage]
	progress_label.text = "🏁  Great job!"

	answer_buttons_container.visible = false
	feedback_label.visible = false
	nav_buttons.visible = true

	prev_button.visible = false
	next_button.visible = true
	next_button.disabled = false
	next_button.text = "🏠  Back to Levels"

	# Safely reconnect next button to finish function
	if next_button.pressed.is_connected(_on_next_pressed):
		next_button.pressed.disconnect(_on_next_pressed)
	next_button.pressed.connect(_on_finish_pressed)
	
	# ✅ Unlock Level 4!
	GameProgress.complete_level(3, quiz_score, quiz.size())

func _on_finish_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

# ─── TRAIN ANIMATION ───────────────────────────────────────

func update_train_position(step: int) -> void:
	step = clampi(step, 0, total_steps)
	var progress: float = float(step) / float(total_steps)

	# Train travels from X:90 (start flag) to X:1150 (end station)
	var target_x: float = 90.0 + progress * (1150.0 - 90.0)

	var tween = create_tween()
	tween.tween_property(train_icon, "position:x", target_x, 0.6) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	print("🚂 Train → step %d/%d  (%.0f%%)" % [step, total_steps, progress * 100.0])
