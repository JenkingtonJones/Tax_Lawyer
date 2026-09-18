extends Node2D

const PLAYER_SPEED := 235.0
const WALK_LEFT_LIMIT := 82.0
const WALK_RIGHT_LIMIT := 1198.0
const PLAYER_FLOOR_Y := 548.0
const JUMP_VELOCITY := -760.0
const JUMP_GRAVITY := 1800.0
const PLAYER_FRAME_SCALE := Vector2(0.42, 0.42)
const GAME_STATE_SCRIPT := preload("res://scripts/GameState.gd")
const HOME_GRID_SCENE_PATH := "res://scenes/HomeGrid.tscn"
const DIALOGUE_BOX_MENU_POSITION := Vector2(522, 92)
const DIALOGUE_BOX_RESULT_POSITION := Vector2(522, 120)
const DIALOGUE_BOX_MENU_SCALE := Vector2(1.30, 0.40)
const DIALOGUE_BOX_RESULT_SCALE := Vector2(1.30, 0.54)
const DIALOGUE_TEXT_MENU_RECT := Rect2(56, 36, 928, 96)
const DIALOGUE_TEXT_RESULT_RECT := Rect2(56, 52, 928, 136)
const CHOICE_BOX_MENU_POSITION := Vector2(522, 218)
const CHOICE_BOX_MENU_SCALE := Vector2(2.00, 0.50)
const CHOICES_MENU_RECT := Rect2(72, 158, 900, 132)
const INTRO_PAGES := [
	"Tax Tribunal - Meaning of 'Of'\nMember Vale has read the formula, the invoice, and the mixing sheet. She has also underlined the word 'of' six times.",
	"Member Vale: Counsel, the word is short. That is not permission to make your answer short. Take me through the goods as imported.",
]
const DECISION_PAGES := [
	"Member Vale: The goods are a flavoured food preparation used to make gelato. Milk solids are a component, not the identity of the whole.",
	"The word 'of' is short, counsel, but not infinitely elastic. If containing milk were enough, biscuits would require a dairy hearing.",
	"Appeal allowed. The product is not a cow in powdered form. The clerk records this with admirable neutrality.",
	"Case complete: $260 fee, audit risk reduced, and one more client matter closed.",
]
const ROUNDS := [
	{
		"prompt": "Member Vale: Describe the imported goods as a whole.",
		"choices": [
			"Milk powder with ambitious flavouring.",
			"A dry flavoured dessert preparation used to make gelato.",
			"Three pallets and a customs mood.",
		],
		"answer": 2,
		"success": "Member Vale: Useful. We classify what crossed the border, not the ingredient with the best lobby.",
		"wrong": "Member Vale: That answer promotes one ingredient or one inconvenience into the entire product. Try again.",
	},
	{
		"prompt": "Member Vale: How should the phrase 'of milk' be read here?",
		"choices": [
			"It must describe the product's essential character, not mere ingredient presence.",
			"It expands to cover anything that has met milk socially.",
			"It means whichever heading produces the longest memo.",
		],
		"answer": 1,
		"success": "Member Vale: The word 'of' connects the heading to the character of the goods. It is not an ingredient search function.",
		"wrong": "Member Vale: Parliament used a preposition, not an infinitely elastic storage bin. Try again.",
	},
	{
		"prompt": "Member Vale: What does the production record establish?",
		"choices": [
			"Nothing. A coffee ring compromised the entire law of evidence.",
			"Manufacturing is irrelevant whenever a bag contains powder.",
			"Sugar, starch, and flavouring form the blend; minority milk solids are one added component.",
		],
		"answer": 3,
		"success": "Member Vale: The process confirms the product was assembled as a preparation. The product is not a cow in powdered form.",
		"wrong": "Member Vale: The batch sequence is in evidence and the coffee ring is not. Try again.",
	},
]

var current_round := 0
var mistakes := 0
var waiting_for_continue := false
var pending_action := ""
var result_pages: Array = []
var result_page_index := 0
var player_frozen := false
var near_hearing_area := false
var vertical_velocity := 0.0
var is_jumping := false

@onready var player: CharacterBody2D = $World/Player
@onready var player_sprite: AnimatedSprite2D = $World/Player/Sprite
@onready var hearing_area: Area2D = $World/HearingArea
@onready var dialogue_panel: Control = $UI/DialoguePanel
@onready var dialogue_box: Sprite2D = $UI/DialoguePanel/DialogueBox
@onready var dialogue_text: Label = $UI/DialoguePanel/DialogueText
@onready var choice_box: Sprite2D = $UI/DialoguePanel/ChoiceBox
@onready var choices: VBoxContainer = $UI/DialoguePanel/Choices
@onready var prompt: Label = $UI/Prompt
@onready var top_hud_text: Label = $UI/TopHudText
@onready var bottom_hud_text: Label = $UI/BottomHudText
@onready var choice_1: Button = $UI/DialoguePanel/Choices/Choice1
@onready var choice_2: Button = $UI/DialoguePanel/Choices/Choice2
@onready var choice_3: Button = $UI/DialoguePanel/Choices/Choice3

func _ready() -> void:
	_setup_text_layout()
	_setup_animations()
	_connect_signals()
	player_sprite.play("idle")
	dialogue_panel.hide()
	prompt.hide()
	_update_hud()

	var game_state := _game_state()
	if bool(game_state.get("meaning_of_case_completed")):
		_show_pages(["The decision has already been issued. The word 'of' is resting after a difficult morning."], "return_map")
	elif not bool(game_state.get("tribunal_unlocked")):
		_show_pages(["The evidentiary record is incomplete. Visit the Import Warehouse before requesting a hearing."], "return_map")
	else:
		prompt.text = "Walk to counsel table"
		prompt.show()

func _setup_text_layout() -> void:
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
	dialogue_text.clip_contents = true
	for button in [choice_1, choice_2, choice_3]:
		button.custom_minimum_size = Vector2(900, 34)
		button.add_theme_font_size_override("font_size", 15)
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

func _setup_animations() -> void:
	player_sprite.sprite_frames = SpriteFrames.new()
	_add_animation(player_sprite.sprite_frames, "idle", "res://assets/processed/player/idle/player_idle_%02d.png", 4, 5.0)
	_add_animation(player_sprite.sprite_frames, "walk", "res://assets/processed/player/walk/player_walk_%02d.png", 4, 8.0)
	player_sprite.scale = PLAYER_FRAME_SCALE

func _add_animation(frames: SpriteFrames, animation_name: StringName, path_pattern: String, count: int, speed: float) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, true)
	frames.set_animation_speed(animation_name, speed)
	for index in range(1, count + 1):
		frames.add_frame(animation_name, load(path_pattern % index) as Texture2D)

func _connect_signals() -> void:
	hearing_area.body_entered.connect(_on_hearing_area_entered)
	hearing_area.body_exited.connect(_on_hearing_area_exited)
	choice_1.pressed.connect(func(): _select_choice(1))
	choice_2.pressed.connect(func(): _select_choice(2))
	choice_3.pressed.connect(func(): _select_choice(3))

func _physics_process(delta: float) -> void:
	if player_frozen:
		player.velocity = Vector2.ZERO
		return

	var direction := Input.get_axis("ui_left", "ui_right")
	if Input.is_action_just_pressed("jump") and not is_jumping:
		vertical_velocity = JUMP_VELOCITY
		is_jumping = true
	if is_jumping:
		vertical_velocity += JUMP_GRAVITY * delta

	player.velocity = Vector2(direction * PLAYER_SPEED, vertical_velocity)
	player.move_and_slide()
	player.position.x = clampf(player.position.x, WALK_LEFT_LIMIT, WALK_RIGHT_LIMIT)
	if player.position.y >= PLAYER_FLOOR_Y:
		player.position.y = PLAYER_FLOOR_Y
		vertical_velocity = 0.0
		is_jumping = false

	if direction < 0.0:
		player_sprite.flip_h = true
		player_sprite.play("walk")
	elif direction > 0.0:
		player_sprite.flip_h = false
		player_sprite.play("walk")
	elif is_jumping:
		player_sprite.play("walk")
	else:
		player_sprite.play("idle")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if waiting_for_continue:
			_mark_input_handled()
			_advance_continue()
		elif near_hearing_area and not player_frozen:
			_mark_input_handled()
			player_frozen = true
			player.velocity = Vector2.ZERO
			_show_pages(INTRO_PAGES, "next_round")
		return

	if waiting_for_continue or not dialogue_panel.visible or not choices.visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_select_choice(1)
			KEY_2:
				_select_choice(2)
			KEY_3:
				_select_choice(3)

func _on_hearing_area_entered(body: Node2D) -> void:
	if body != player:
		return
	near_hearing_area = true
	if not player_frozen:
		prompt.text = "Press E: begin hearing"
		prompt.show()

func _on_hearing_area_exited(body: Node2D) -> void:
	if body != player:
		return
	near_hearing_area = false
	if not player_frozen:
		prompt.text = "Walk to counsel table"
		prompt.show()

func _show_round() -> void:
	waiting_for_continue = false
	pending_action = ""
	var round_data: Dictionary = ROUNDS[current_round]
	_set_menu_layout()
	_set_dialogue_text(round_data["prompt"])
	_set_choice_texts(round_data["choices"])
	choice_box.show()
	choices.show()
	dialogue_panel.show()
	prompt.text = "Press 1, 2, or 3"
	prompt.show()
	choice_1.grab_focus()
	_update_hud()

func _select_choice(option: int) -> void:
	if waiting_for_continue or current_round >= ROUNDS.size():
		return
	var round_data: Dictionary = ROUNDS[current_round]
	choice_box.hide()
	choices.hide()

	if option != int(round_data["answer"]):
		mistakes += 1
		var game_state := _game_state()
		game_state.set("stamina", clampi(int(game_state.get("stamina")) - 2, 0, 100))
		game_state.set("audit_risk", clampi(int(game_state.get("audit_risk")) + 2, 0, 100))
		_update_hud()
		_show_pages([round_data["wrong"]], "retry_round")
		return

	var success_text: String = round_data["success"]
	current_round += 1
	if current_round >= ROUNDS.size():
		_game_state().call("complete_meaning_of_case")
		_update_hud()
		var final_pages := [success_text]
		final_pages.append_array(DECISION_PAGES)
		_show_pages(final_pages, "return_map")
	else:
		_update_hud()
		_show_pages([success_text], "next_round")

func _show_pages(pages: Array, next_action: String) -> void:
	result_pages = pages
	result_page_index = 0
	pending_action = next_action
	player_frozen = true
	_set_result_layout()
	_set_dialogue_text(result_pages[result_page_index])
	choice_box.hide()
	choices.hide()
	dialogue_panel.show()
	waiting_for_continue = true
	_update_continue_prompt()

func _advance_continue() -> void:
	if result_page_index < result_pages.size() - 1:
		result_page_index += 1
		_set_result_layout()
		_set_dialogue_text(result_pages[result_page_index])
		_update_continue_prompt()
		return

	match pending_action:
		"next_round", "retry_round":
			_show_round()
		"return_map":
			get_tree().change_scene_to_file(HOME_GRID_SCENE_PATH)

func _update_continue_prompt() -> void:
	if result_page_index < result_pages.size() - 1 or pending_action in ["next_round", "retry_round"]:
		prompt.text = "Press E to continue"
	else:
		prompt.text = "Press E to open map"
	prompt.show()

func _set_choice_texts(choice_texts: Array) -> void:
	choice_1.text = "1. %s" % choice_texts[0]
	choice_2.text = "2. %s" % choice_texts[1]
	choice_3.text = "3. %s" % choice_texts[2]

func _set_menu_layout() -> void:
	dialogue_box.position = DIALOGUE_BOX_MENU_POSITION
	dialogue_box.scale = DIALOGUE_BOX_MENU_SCALE
	dialogue_text.position = DIALOGUE_TEXT_MENU_RECT.position
	dialogue_text.size = DIALOGUE_TEXT_MENU_RECT.size
	choice_box.position = CHOICE_BOX_MENU_POSITION
	choice_box.scale = CHOICE_BOX_MENU_SCALE
	choices.position = CHOICES_MENU_RECT.position
	choices.size = CHOICES_MENU_RECT.size

func _set_result_layout() -> void:
	dialogue_box.position = DIALOGUE_BOX_RESULT_POSITION
	dialogue_box.scale = DIALOGUE_BOX_RESULT_SCALE
	dialogue_text.position = DIALOGUE_TEXT_RESULT_RECT.position
	dialogue_text.size = DIALOGUE_TEXT_RESULT_RECT.size

func _set_dialogue_text(text: String) -> void:
	var font_size := 18
	if text.length() > 280:
		font_size = 14
	elif text.length() > 170:
		font_size = 16
	dialogue_text.add_theme_font_size_override("font_size", font_size)
	dialogue_text.text = text

func _update_hud() -> void:
	var game_state := _game_state()
	top_hud_text.text = "TAX TRIBUNAL      Argument %d/3      Objections %d" % [mini(current_round + 1, 3), mistakes]
	bottom_hud_text.text = "Money $%d      Stamina %d                         Audit Risk %s" % [
		int(game_state.get("money")),
		int(game_state.get("stamina")),
		_audit_label(),
	]

func _audit_label() -> String:
	var audit_risk := int(_game_state().get("audit_risk"))
	if audit_risk < 35:
		return "Low"
	if audit_risk < 70:
		return "Medium"
	return "High"

func _game_state() -> Node:
	var root := get_tree().root
	if root.has_node("GameState"):
		return root.get_node("GameState")
	var game_state: Node = GAME_STATE_SCRIPT.new()
	game_state.name = "GameState"
	root.add_child(game_state)
	return game_state

func _mark_input_handled() -> void:
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
