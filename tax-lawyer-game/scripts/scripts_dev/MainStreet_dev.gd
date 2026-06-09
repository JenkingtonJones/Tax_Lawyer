extends Node2D

const PLAYER_SPEED := 235.0
const WALK_LEFT_LIMIT := 92.0
const WALK_RIGHT_LIMIT := 1188.0
const PLAYER_FLOOR_Y := 520.0
const JUMP_VELOCITY := -760.0
const JUMP_GRAVITY := 1800.0
const PLAYER_FRAME_SCALE := Vector2(0.42, 0.42)
const NPC_FRAME_SCALE := Vector2(0.42, 0.42)
const INITIAL_DIALOGUE := "I only have receipts. Can you sort them out?"
const STORY_INIT_DIALOGUE := "Oh, my goodness. It's much worse than I thought. It wasn't just messy. There was... a pack rat. A terrible, tiny disaster."
const APPOINTMENT_NEEDED := "Due to the volume and complexity of the filings, I believe a follow-up appointment is necessary. I've left a note for you to check your office schedule shortly!" 
const FACILITATOR_PROMPT := "Oh my... / That sounds hard... / Say more about that..."
const THANK_YOU_DIALOGUE := "Thank you for your help."
const OPTION_1_RESULT := "" # This will be overwritten by the multi-stage dialogue
const FACILITATOR_RESPONSE_1 := "Oh my."
const FACILITATOR_RESPONSE_2 := "That sounds really hard."
const FACILITATOR_RESPONSE_3 := "Could you say more about that?"
const OPTION_2_RESULT := "You accept the receipts and hope the audit gods are merciful. When you get back to the office, you'll have to reconcile them. That sounds fun."
const OPTION_3_RESULT := "You explain that her eligible remittance variance may require a provisional adjustment to the prior-period instalment allocation before the carry-forward balance can be reconciled against the current filing position. She seems reassured."

var money := 850
var stamina := 100
var audit_risk := 50
var clients_completed := 0
var dialogue_phase := 0 # 0: Waiting, 1: Initial Dialogue, 2: Missing Docs Story
var facilitator_count := 0
var story_advanced := false
var player_frozen := false
var near_client := false
var client_resolved := false
var waiting_for_continue := false
var vertical_velocity := 0.0
var is_jumping := false

@onready var player: CharacterBody2D = $World/Player
@onready var player_sprite: AnimatedSprite2D = $World/Player/Sprite
@onready var client_sprite: AnimatedSprite2D = $World/ElderlyClient/Sprite
@onready var interaction_area: Area2D = $World/ElderlyClient/InteractionArea
@onready var prompt: Label = $UI/Prompt
@onready var dialogue_panel: Control = $UI/DialoguePanel
@onready var dialogue_text: Label = $UI/DialoguePanel/DialogueText
@onready var choice_box: Sprite2D = $UI/DialoguePanel/ChoiceBox
@onready var choices: VBoxContainer = $UI/DialoguePanel/Choices
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
	client_sprite.play("idle")
	dialogue_panel.hide()
	prompt.hide()
	_update_hud()

func _setup_text_layout() -> void:
	dialogue_text.custom_minimum_size = Vector2(590, 132)
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
	dialogue_text.clip_contents = true

	choices.clip_contents = true
	choice_1.text = "1. Missing docs"
	choice_2.text = "2. Accept receipts"
	choice_3.text = "3. CRA guidance"

	for button in [choice_1, choice_2, choice_3]:
		button.custom_minimum_size = Vector2(342, 32)
		button.add_theme_font_size_override("font_size", 17)
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

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
			_close_dialogue()
			get_viewport().set_input_as_handled()
		elif near_client and not player_frozen:
			_open_dialogue()
			get_viewport().set_input_as_handled()
		return

	if player_frozen and dialogue_panel.visible and choices.visible and event is InputEventKey and event.pressed and not event.echo:
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

	client_sprite.sprite_frames = SpriteFrames.new()
	_add_animation(client_sprite.sprite_frames, "idle", "res://assets/processed/npcs/elderly_client/idle/client_elderly_idle_%02d.png", 4, 4.0)
	_add_animation(client_sprite.sprite_frames, "worried", "res://assets/processed/npcs/elderly_client/worried/client_elderly_worried_%02d.png", 4, 6.0)
	client_sprite.scale = NPC_FRAME_SCALE

func _add_animation(frames: SpriteFrames, animation_name: StringName, path_pattern: String, count: int, speed: float) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, true)
	frames.set_animation_speed(animation_name, speed)

	for index in range(1, count + 1):
		var texture := load(path_pattern % index) as Texture2D
		frames.add_frame(animation_name, texture)

func _connect_signals() -> void:
	interaction_area.body_entered.connect(_on_interaction_body_entered)
	interaction_area.body_exited.connect(_on_interaction_body_exited)
	choice_1.pressed.connect(func(): _select_choice(1))
	choice_2.pressed.connect(func(): _select_choice(2))
	choice_3.pressed.connect(func(): _select_choice(3))

func _on_interaction_body_entered(body: Node2D) -> void:
	if body == player:
		near_client = true
		if not player_frozen:
			prompt.show()

func _on_interaction_body_exited(body: Node2D) -> void:
	if body == player:
		near_client = false
		prompt.hide()

func _open_dialogue() -> void:
	player_frozen = true
	player.velocity = Vector2.ZERO
	prompt.hide()
	waiting_for_continue = false
	_set_dialogue_text(THANK_YOU_DIALOGUE if client_resolved else INITIAL_DIALOGUE)
	choice_box.visible = not client_resolved
	choices.visible = not client_resolved
	dialogue_panel.show()
	if client_resolved:
		_show_continue_prompt()
	else:
		choice_1.grab_focus()

func _select_choice(option: int) -> void:
	if client_resolved or not dialogue_panel.visible or not choices.visible:
		return

	match option:
		1:
			_apply_choice(-10, -10, 0, 0, OPTION_1_RESULT)
		2:
			_apply_choice(0, 20, 150, 1, OPTION_2_RESULT)
		3:
			_apply_choice(-5, -5, 0, 1, OPTION_3_RESULT)

func _apply_choice(stamina_delta: int, audit_delta: int, money_delta: int, client_delta: int, result_text: String) -> void:
	stamina = clampi(stamina + stamina_delta, 0, 100)
	audit_risk = clampi(audit_risk + audit_delta, 0, 100)
	money += money_delta
	clients_completed = clampi(clients_completed + client_delta, 0, 5)
	client_resolved = true
	_update_hud()
	_set_dialogue_text(result_text)
	choice_box.hide()
	choices.hide()
	_show_continue_prompt()
	_play_worried_briefly()

func _close_dialogue() -> void:
	dialogue_panel.hide()
	player_frozen = false
	waiting_for_continue = false
	if near_client:
		prompt.text = "Press E to talk"
		prompt.show()

func _show_continue_prompt() -> void:
	waiting_for_continue = true
	prompt.text = "Press E to continue"
	prompt.show()

func _set_dialogue_text(text: String) -> void:
	var font_size := 18
	if text.length() > 220:
		font_size = 14
	elif text.length() > 130:
		font_size = 16

	dialogue_text.add_theme_font_size_override("font_size", font_size)
	dialogue_text.text = text

func _play_worried_briefly() -> void:
	client_sprite.play("worried")
	await get_tree().create_timer(1.0).timeout
	client_sprite.play("idle")

func _update_hud() -> void:
	top_hud_text.text = "Clients %d/5    Time 1:30" % clients_completed
	bottom_hud_text.text = "Money $%d      Stamina %d                         Audit Risk %s" % [
		money,
		stamina,
		_audit_label(),
	]

func _audit_label() -> String:
	if audit_risk < 35:
		return "Low"
	if audit_risk < 70:
		return "Medium"
	return "High"
