extends Node2D

const GAME_STATE_SCRIPT := preload("res://scripts/GameState.gd")
const HOME_GRID_SCENE_PATH := "res://scenes/HomeGrid.tscn"
const DIALOGUE_BOX_MENU_POSITION := Vector2(305, 120)
const DIALOGUE_BOX_RESULT_POSITION := Vector2(522, 120)
const DIALOGUE_BOX_MENU_SCALE := Vector2(0.68, 0.54)
const DIALOGUE_BOX_RESULT_SCALE := Vector2(1.30, 0.54)
const DIALOGUE_TEXT_MENU_RECT := Rect2(56, 52, 480, 136)
const DIALOGUE_TEXT_RESULT_RECT := Rect2(56, 52, 928, 136)
const CHOICE_BOX_MENU_POSITION := Vector2(812, 120)
const CHOICE_BOX_MENU_SCALE := Vector2(0.78, 0.58)
const CHOICES_MENU_RECT := Rect2(640, 58, 326, 120)
const TASK_LABELS := [
	"1. Missing-doc list",
	"2. Sort receipts",
	"3. Intake memo",
]
const TASK_RESULTS := [
	"You build a short list: payroll slips, bank statements, the missing invoice, and the second folder from the hall closet. The client nods like this is both helpful and personally accusing.",
	"You sort the receipts into income, expenses, mystery paper, and things that were probably once paper. The audit risk drops because the file now has visible categories.",
	"You draft the intake memo and set the follow-up appointment. The file is no longer a sidewalk emergency; it is now a normal office problem.",
]
const INTRO_TEXT := "10:00 AM - Office Intake\nThe client arrives with the receipt bag, one damaged folder, and a very apologetic expression. Start by getting the file into a usable shape."
const COMPLETE_TEXT := "Office intake complete.\nThe missing documents are listed, the receipts are sorted, and the follow-up memo is ready for the file."

var completed_tasks: Array[int] = []
var waiting_for_continue := false
var intake_complete := false

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
	_connect_signals()
	_show_task_menu()
	_update_hud()

func _setup_text_layout() -> void:
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
	dialogue_text.clip_contents = true

	for button in [choice_1, choice_2, choice_3]:
		button.custom_minimum_size = Vector2(326, 32)
		button.add_theme_font_size_override("font_size", 17)
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

func _connect_signals() -> void:
	choice_1.pressed.connect(func(): _select_choice(1))
	choice_2.pressed.connect(func(): _select_choice(2))
	choice_3.pressed.connect(func(): _select_choice(3))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and waiting_for_continue:
		_mark_input_handled()
		if intake_complete:
			_game_state().set("map_spawn", "law_office")
			get_tree().change_scene_to_file(HOME_GRID_SCENE_PATH)
		else:
			_show_task_menu()
		return

	if waiting_for_continue or intake_complete or not choices.visible:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_select_choice(1)
			KEY_2:
				_select_choice(2)
			KEY_3:
				_select_choice(3)

func _show_task_menu() -> void:
	waiting_for_continue = false
	_set_menu_layout()
	_set_dialogue_text(INTRO_TEXT)
	choice_box.show()
	choices.show()
	prompt.text = "Press 1, 2, or 3"
	prompt.show()

	_set_button_state(choice_1, 1)
	_set_button_state(choice_2, 2)
	_set_button_state(choice_3, 3)
	_grab_next_available_focus()

func _select_choice(option: int) -> void:
	if waiting_for_continue or completed_tasks.has(option):
		return

	completed_tasks.append(option)
	var game_state := _game_state()
	match option:
		1:
			game_state.set("office_unlocked", true)
		2:
			game_state.set("audit_risk", clampi(int(game_state.get("audit_risk")) - 12, 0, 100))
		3:
			game_state.set("office_completed", true)
			game_state.set("clients_completed", maxi(int(game_state.get("clients_completed")), 1))

	_set_result_layout()
	_set_dialogue_text(TASK_RESULTS[option - 1])
	choice_box.hide()
	choices.hide()
	_update_hud()

	if completed_tasks.size() >= TASK_LABELS.size():
		_finish_intake()
	else:
		waiting_for_continue = true
		prompt.text = "Press E to continue"
		prompt.show()

func _finish_intake() -> void:
	intake_complete = true
	waiting_for_continue = true
	_set_result_layout()
	_set_dialogue_text("%s\n\n%s" % [dialogue_text.text, COMPLETE_TEXT])
	prompt.text = "Press E to return to map"
	prompt.show()

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
	if text.length() > 260:
		font_size = 14
	elif text.length() > 170:
		font_size = 16

	dialogue_text.add_theme_font_size_override("font_size", font_size)
	dialogue_text.text = text

func _set_button_state(button: Button, option: int) -> void:
	button.text = "[done] %s" % TASK_LABELS[option - 1].substr(3) if completed_tasks.has(option) else TASK_LABELS[option - 1]
	button.disabled = completed_tasks.has(option)

func _grab_next_available_focus() -> void:
	for button in [choice_1, choice_2, choice_3]:
		if not button.disabled:
			button.grab_focus()
			return

func _update_hud() -> void:
	var game_state := _game_state()
	top_hud_text.text = "OFFICE INTAKE      Tasks %d/3" % completed_tasks.size()
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
