extends Control

# ========================================
# LEVEL DATA - Types of Network
# ========================================

var level_title = "Types of Network"

var slides = [
	"Types of Network\n\nNetworks like PAN, LAN, WAN, MAN enable computers to connect and communicate with each other, and they vary in scope, size, and purposes. Ranging from small personal networks to large global systems.",
	
	"PAN - Personal Area Network\n\nA PAN is a short-range network that connects personal devices like smartphones, tablets, and computers. It typically covers less than 10 meters (about 33 feet) and usually uses wireless technologies such as Bluetooth. PAN is smaller than other networks like LAN or WAN and is mainly used for data sharing between a few devices.",
	
	"LAN - Local Area Network\n\nA LAN connects computers and devices within a small area like a home, office, school, or hospital. It usually uses switches, routers, and private IP addresses. LANs are high-speed, inexpensive to set up, and easy to maintain.",
	
	"MAN - Metropolitan Area Network\n\nA MAN spans 5–50 km, covering more area than a LAN but less than a WAN. It connects computers across a city or between nearby cities. MANs provide high-speed connectivity (in Mbps), can act as ISPs, and are useful for organizations needing fast communication. However, they are costly, complex to design, and harder to maintain.",
	
	"WAN - Wide Area Network\n\nA WAN covers large geographical areas (above 50 km), often connecting multiple LANs through telephone lines, radio waves, or satellites. It can be private (for organizations) or public (like the internet). WANs offer high-speed communication but are costly to set up and maintain."
]

var passengers = [
	{
		"description": "A short-range network that connects personal devices like smartphones, tablets, and smartwatches within a few meters.",
		"correct_wagon": "PAN"
	},
	{
		"description": "Connects devices within a building or campus like a home, office, or school, typically using switches and routers.",
		"correct_wagon": "LAN"
	},
	{
		"description": "Spans a city or metropolitan region, covering an area of 5 to 50 kilometers, connecting computers across nearby cities.",
		"correct_wagon": "MAN"
	},
	{
		"description": "Covers large geographical areas above 50 km, like entire countries or continents. The Internet is the largest example!",
		"correct_wagon": "WAN"
	}
]

# ========================================
# SCRIPT LOGIC
# ========================================

var current_slide: int = 0
var current_passenger_index: int = 0
var total_steps: int = 0
var score: int = 0
var level_finished: bool = false

# Drag and drop state
var is_dragging: bool = false
var drag_start_pos: Vector2
var original_passenger_pos: Vector2

# Node references
@onready var modal_overlay: ColorRect = $ModalOverlay
@onready var popup_panel: PanelContainer = $PopupPanel
@onready var popup_title: Label = $PopupPanel/PopupMargin/PopupContent/PopupTitle
@onready var content_text: Label = $PopupPanel/PopupMargin/PopupContent/ContentText
@onready var progress_label: Label = $PopupPanel/PopupMargin/PopupContent/ProgressLabel
@onready var prev_button: Button = $PopupPanel/PopupMargin/PopupContent/NavButtons/PrevButton
@onready var next_button: Button = $PopupPanel/PopupMargin/PopupContent/NavButtons/NextButton
@onready var close_button: Button = $PopupPanel/TopRightAnchor/CloseButton
@onready var game_area: Control = $GameArea
@onready var passenger_card: PanelContainer = $GameArea/PassengerCard
@onready var ticket_info_label: Label = $GameArea/PassengerCard/Margin/Content/TicketInfo
@onready var feedback_label: Label = $GameArea/FeedbackLabel
@onready var instruction_label: Label = $GameArea/InstructionLabel
@onready var train_icon: Label = $ProgressBarContainer/TrainIcon
@onready var wagons_container: HBoxContainer = $GameArea/WagonsContainer

# Wagon references
@onready var pan_wagon: PanelContainer = $GameArea/WagonsContainer/PAN_Wagon
@onready var lan_wagon: PanelContainer = $GameArea/WagonsContainer/LAN_Wagon
@onready var man_wagon: PanelContainer = $GameArea/WagonsContainer/MAN_Wagon
@onready var wan_wagon: PanelContainer = $GameArea/WagonsContainer/WAN_Wagon

func _ready() -> void:
	total_steps = slides.size() + passengers.size()
	
	# Connect slide buttons
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	# Set train at start
	train_icon.position.x = 90.0
	
	# Hide game area initially
	game_area.visible = false
	modal_overlay.visible = false
	popup_panel.visible = false
	
	# Show first slide after delay
	await get_tree().create_timer(0.5).timeout
	show_popup()
	load_slide(0)

# ─── POPUP & SLIDES ────────────────────────────────────────

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

func load_slide(index: int) -> void:
	popup_title.text = level_title
	content_text.text = slides[index]
	progress_label.text = "📖  Slide %d / %d" % [index + 1, slides.size()]
	
	prev_button.disabled = (index == 0)
	next_button.text = "Start Game! →" if index == slides.size() - 1 else "Next →"

func _on_prev_pressed() -> void:
	if current_slide > 0:
		current_slide -= 1
		load_slide(current_slide)
		update_train_position(current_slide)

func _on_next_pressed() -> void:
	if current_slide < slides.size() - 1:
		current_slide += 1
		load_slide(current_slide)
		update_train_position(current_slide)
	else:
		# Start game after slides
		update_train_position(slides.size())
		start_game()

func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

# ─── GAME START ────────────────────────────────────────────

func start_game() -> void:
	await hide_popup()
	game_area.visible = true
	original_passenger_pos = passenger_card.position
	load_passenger(0)

func load_passenger(index: int) -> void:
	if index >= passengers.size():
		finish_level()
		return
	
	current_passenger_index = index
	var passenger = passengers[index]
	
	ticket_info_label.text = passenger["description"]
	feedback_label.visible = false
	instruction_label.text = "🎫 Passenger %d of %d - Drag to correct wagon!" % [index + 1, passengers.size()]
	
	# Reset passenger position
	passenger_card.position = original_passenger_pos
	passenger_card.modulate = Color(1, 1, 1, 1)

# ─── DRAG AND DROP LOGIC ───────────────────────────────────

func _input(event: InputEvent) -> void:
	if not game_area.visible or level_finished:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Check if clicked on passenger card
				var card_rect = Rect2(passenger_card.global_position, passenger_card.size)
				if card_rect.has_point(event.position):
					is_dragging = true
					drag_start_pos = event.position
			else:
				# Released mouse
				if is_dragging:
					is_dragging = false
					check_drop()
	
	elif event is InputEventMouseMotion and is_dragging:
		# Move passenger card with mouse
		var offset = event.position - drag_start_pos
		passenger_card.position = original_passenger_pos + offset

func check_drop() -> void:
	var passenger = passengers[current_passenger_index]
	var dropped_wagon = get_wagon_at_mouse()
	
	if dropped_wagon == "":
		# Not dropped on any wagon - return to original position
		animate_return()
		return
	
	if dropped_wagon == passenger["correct_wagon"]:
		# Correct!
		on_correct_drop()
	else:
		# Wrong wagon
		on_wrong_drop(dropped_wagon, passenger["correct_wagon"])

func get_wagon_at_mouse() -> String:
	var mouse_pos = get_global_mouse_position()
	
	var wagons = {
		"PAN": pan_wagon,
		"LAN": lan_wagon,
		"MAN": man_wagon,
		"WAN": wan_wagon
	}
	
	for wagon_name in wagons:
		var wagon = wagons[wagon_name]
		var rect = Rect2(wagon.global_position, wagon.size)
		if rect.has_point(mouse_pos):
			return wagon_name
	
	return ""

# ─── FEEDBACK ANIMATIONS ───────────────────────────────────

func on_correct_drop() -> void:
	score += 1
	feedback_label.text = "✓ Correct!"
	feedback_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	feedback_label.visible = true
	
	# Animate passenger into wagon
	var tween = create_tween()
	tween.tween_property(passenger_card, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func(): passenger_card.visible = false)
	
	# Update train
	update_train_position(slides.size() + current_passenger_index + 1)
	
	# Wait then load next passenger
	await get_tree().create_timer(1.5).timeout
	passenger_card.visible = true
	passenger_card.modulate.a = 1.0
	feedback_label.visible = false
	load_passenger(current_passenger_index + 1)

func on_wrong_drop(dropped: String, correct: String) -> void:
	feedback_label.text = "✗ Wrong! This belongs in %s wagon, not %s" % [correct, dropped]
	feedback_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
	feedback_label.visible = true
	
	# Shake animation
	var original = passenger_card.position
	var tween = create_tween()
	tween.tween_property(passenger_card, "position:x", original.x - 15, 0.05)
	tween.tween_property(passenger_card, "position:x", original.x + 15, 0.05)
	tween.tween_property(passenger_card, "position:x", original.x - 10, 0.05)
	tween.tween_property(passenger_card, "position:x", original.x + 10, 0.05)
	tween.tween_property(passenger_card, "position", original, 0.05)
	
	# Return to original position after shake
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	feedback_label.visible = false
	animate_return()

func animate_return() -> void:
	var tween = create_tween()
	tween.tween_property(passenger_card, "position", original_passenger_pos, 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# ─── LEVEL COMPLETE ────────────────────────────────────────

func finish_level() -> void:
	level_finished = true
	var percentage = (float(score) / passengers.size()) * 100.0
	
	# Train reaches station
	update_train_position(total_steps)
	
	# Unlock Level 3!
	GameProgress.complete_level(2, score, passengers.size())
	
	# Hide game elements
	passenger_card.visible = false
	instruction_label.visible = false
	
	# Show completion message
	feedback_label.text = "🎉 Level Complete!\n\nYou sorted %d/%d passengers correctly!" % [score, passengers.size()]
	feedback_label.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	feedback_label.visible = true
	
	# Wait then return to level select
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

# ─── TRAIN ANIMATION ───────────────────────────────────────

func update_train_position(step: int) -> void:
	step = clampi(step, 0, total_steps)
	var progress = float(step) / float(total_steps)
	var target_x = 90.0 + progress * (1150.0 - 90.0)
	
	var tween = create_tween()
	tween.tween_property(train_icon, "position:x", target_x, 0.6) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	print("🚂 Train → step %d/%d  (%.0f%%)" % [step, total_steps, progress * 100.0])
