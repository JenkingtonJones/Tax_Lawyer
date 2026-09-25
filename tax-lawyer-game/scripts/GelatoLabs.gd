extends Node2D

const PLAYER_SPEED := 235.0
const WALK_LEFT_LIMIT := 92.0
const WALK_RIGHT_LIMIT := 1188.0
const PLAYER_FLOOR_Y := 532.0
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
const INTRO_TEXT := "Gelato Labs\nThe CRA representative is already in the corner booth. He has sunglasses, a clipboard, and a tiny spoon. None of these items seem optional."
const MEETING_PROMPT := "Agent Ledger: You are the lawyer seeking guidance on the receipt matter?"
const WRONG_TEXT := "Agent Ledger stares over his sunglasses. \"That is not acceptable for administrative clarity.\" He waits for you to try again."
const SUCCESS_PAGES := [
	"Agent Ledger: Accepted. The taxpayer may attend with the materials, provided the materials are sorted, labelled, and not sticky.",
	"You set a time for official guidance. Agent Ledger writes it on a napkin, stamps the napkin, and files it in a folder marked PISTACHIO.",
	"Now you need to return to the client and tell her the guidance is ready.",
]
const CHOICE_TEXTS := [
	"Ask if pistachio is deductible.",
	"Confirm the client needs pre-filing guidance.",
	"Say \"the eagle files at dawn.\"",
]
const CORRECT_CHOICE := 2

var waiting_for_continue := false
var pending_action := ""
var result_pages: Array = []
var result_page_index := 0
var player_frozen := false
var near_agent := false
var vertical_velocity := 0.0
var is_jumping := false

@onready var player: CharacterBody2D = $Characters/Player
@onready var player_sprite: AnimatedSprite2D = $Characters/Player/Sprite
@onready var interaction_area: Area2D = $Characters/AgentLedger/InteractionArea
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
	$UI/DialoguePanel.hide()
	prompt.hide()
	_update_hud()
	if bool(_game_state().get("cra_meeting_scheduled")):
		_show_pages(["The Gelato Labs meeting is already scheduled. Return to the client at the Tax Office street."], "return_map")
	elif not bool(_game_state().get("cra_call_completed")):
		_show_pages(["No representative is here yet. Make the CRA guidance call from the Law Office first."], "return_map")
	else:
		prompt.text = "Find Agent Ledger"
		prompt.show()

func _setup_text_layout() -> void:
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
	dialogue_text.clip_contents = true

	for button in [choice_1, choice_2, choice_3]:
		button.custom_minimum_size = Vector2(900, 34)
		button.add_theme_font_size_override("font_size", 15)
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

func _connect_signals() -> void:
	interaction_area.body_entered.connect(_on_interaction_body_entered)
	interaction_area.body_exited.connect(_on_interaction_body_exited)
	choice_1.pressed.connect(func(): _select_choice(1))
	choice_2.pressed.connect(func(): _select_choice(2))
	choice_3.pressed.connect(func(): _select_choice(3))

func _physics_process(_delta: float) -> void:
	if player_frozen:
		player.velocity = Vector2.ZERO
		return

	var direction := Input.get_axis("ui_left", "ui_right")
	if Input.is_action_just_pressed("jump") and not is_jumping:
		vertical_velocity = JUMP_VELOCITY
		is_jumping = true

	if is_jumping:
		vertical_velocity += JUMP_GRAVITY * _delta

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
		elif near_agent and not player_frozen:
			_mark_input_handled()
			_open_agent_dialogue()
		return

	if waiting_for_continue or not choices.visible:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_select_choice(1)
			KEY_2:
				_select_choice(2)
			KEY_3:
				_select_choice(3)

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
		var texture := load(path_pattern % index) as Texture2D
		frames.add_frame(animation_name, texture)

func _on_interaction_body_entered(body: Node2D) -> void:
	if body == player:
		near_agent = true
		if not player_frozen:
			prompt.text = "Press E to talk"
			prompt.show()

func _on_interaction_body_exited(body: Node2D) -> void:
	if body == player:
		near_agent = false
		if not player_frozen:
			prompt.hide()

func _open_agent_dialogue() -> void:
	player_frozen = true
	player.velocity = Vector2.ZERO
	prompt.hide()
	_show_pages([INTRO_TEXT], "show_meeting")

func _show_meeting_question() -> void:
	waiting_for_continue = false
	pending_action = ""
	_set_menu_layout()
	_set_dialogue_text(MEETING_PROMPT)
	_set_choice_texts(CHOICE_TEXTS)
	choice_box.show()
	choices.show()
	prompt.text = "Press 1, 2, or 3"
	prompt.show()
	choice_1.grab_focus()

func _select_choice(option: int) -> void:
	if waiting_for_continue or not choices.visible:
		return

	choice_box.hide()
	choices.hide()
	if option == CORRECT_CHOICE:
		_finish_meeting()
	else:
		var game_state := _game_state()
		game_state.set("stamina", clampi(int(game_state.get("stamina")) - 2, 0, 100))
		_update_hud()
		_show_pages([WRONG_TEXT], "show_meeting")

func _finish_meeting() -> void:
	var game_state := _game_state()
	var new_stamina := clampi(int(game_state.get("stamina")) - 3, 0, 100)
	game_state.call("schedule_cra_guidance_meeting", new_stamina)
	_update_hud()
	_show_pages(SUCCESS_PAGES, "return_map")

func _show_pages(pages: Array, next_action: String) -> void:
	result_pages = pages
	result_page_index = 0
	pending_action = next_action
	player_frozen = true
	_set_result_layout()
	_set_dialogue_text(result_pages[result_page_index])
	choice_box.hide()
	choices.hide()
	$UI/DialoguePanel.show()
	waiting_for_continue = true
	prompt.text = "Press E to continue" if result_page_index < result_pages.size() - 1 or pending_action == "show_meeting" else "Press E to open map"
	prompt.show()

func _advance_continue() -> void:
	if result_page_index < result_pages.size() - 1:
		result_page_index += 1
		_set_result_layout()
		_set_dialogue_text(result_pages[result_page_index])
		prompt.text = "Press E to continue" if result_page_index < result_pages.size() - 1 or pending_action == "show_meeting" else "Press E to open map"
		prompt.show()
		return

	match pending_action:
		"show_meeting":
			_show_meeting_question()
		"return_map":
			get_tree().change_scene_to_file(HOME_GRID_SCENE_PATH)

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
	top_hud_text.text = "GELATO LABS      CRA Representative"
	bottom_hud_text.text = "Escrow $%d      Coffee %d%%                      Audit Risk %s" % [
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
	var viewport: Viewport = get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
