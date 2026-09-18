extends Node2D

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
const MAX_MISTAKES := 3
const INTRO_TEXT := "Law Office - CRA Guidance Call\nYou close the blinds, put the phone on speaker, and write CASELINE? in block letters. The hold music sounds like a printer warming up in a locked room."
const CORRECT_FEEDBACK := "Correct. The line clicks, pauses, and asks another question as if nothing human has occurred."
const WRONG_FEEDBACK := "Wrong. The hold music grows sharper. You correct the record, but the call has taken something from you."
const FAILURE_TEXT := "A recorded voice thanks you for your interest in administrative clarity. Then the call disconnects. You will have to try the CRA call again from the Law Office."
const SUCCESS_PAGES := [
	"The final answer lands. Somewhere inside the phone system, a gate opens.",
	"CRA Agent: Guidance cannot be completed over this line. A representative will meet you in person.",
	"Lawyer: In person?\n\nCRA Agent: Yes. At Gelato Labs.",
	"Lawyer: That is not a CRA office.\n\nCRA Agent: No. But it has tables, witnesses, and very good pistachio.",
]
const QUESTIONS := [
	{
		"prompt": "Before we continue, identify the nature of your call.",
		"choices": [
			"I am asking whether receipts have feelings.",
			"I am requesting taxpayer-specific guidance for a filing issue.",
			"I would prefer not to identify myself.",
		],
		"answer": 2,
	},
	{
		"prompt": "Is the taxpayer attempting to file immediately?",
		"choices": [
			"She has placed the receipts in a bag, which feels legally meaningful.",
			"Yes, and we are hoping for the best.",
			"No. We are gathering documents before filing.",
		],
		"answer": 3,
	},
	{
		"prompt": "Which documents appear to be missing?",
		"choices": [
			"Payroll slips, bank statements, and at least one invoice.",
			"All documents are present except the ones that matter.",
			"A treasure map, a jam label, and a birthday card.",
		],
		"answer": 1,
	},
	{
		"prompt": "Has the taxpayer separated personal expenses from possible deductible expenses?",
		"choices": [
			"She sorted them by how guilty they looked.",
			"Yes, by emotional importance.",
			"Not yet. That is part of the appointment plan.",
		],
		"answer": 3,
	},
	{
		"prompt": "Why are you requesting guidance?",
		"choices": [
			"To obtain permission to ignore the hard receipts.",
			"To confirm treatment before filing and reduce audit risk.",
			"To make the receipt bag stop making eye contact.",
		],
		"answer": 2,
	},
]

var question_index := 0
var mistakes := 0
var waiting_for_continue := false
var pending_action := ""
var result_pages: Array = []
var result_page_index := 0

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
	_update_hud()
	if bool(_game_state().get("cra_call_completed")):
		_show_pages(["The CRA call is already complete. The next meeting is at Gelato Labs."], "return_map")
	else:
		_show_pages([INTRO_TEXT], "next_question")

func _setup_text_layout() -> void:
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
	dialogue_text.clip_contents = true

	for button in [choice_1, choice_2, choice_3]:
		button.custom_minimum_size = Vector2(900, 34)
		button.add_theme_font_size_override("font_size", 15)
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

func _connect_signals() -> void:
	choice_1.pressed.connect(func(): _select_choice(1))
	choice_2.pressed.connect(func(): _select_choice(2))
	choice_3.pressed.connect(func(): _select_choice(3))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and waiting_for_continue:
		_mark_input_handled()
		_advance_continue()
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

func _show_question() -> void:
	waiting_for_continue = false
	pending_action = ""
	var question: Dictionary = QUESTIONS[question_index]
	var option_texts: Array = question["choices"]
	_set_menu_layout()
	_set_dialogue_text(question["prompt"])
	_set_choice_texts(option_texts)
	choice_box.show()
	choices.show()
	prompt.text = "Press 1, 2, or 3"
	prompt.show()
	choice_1.grab_focus()
	_update_hud()

func _select_choice(option: int) -> void:
	if waiting_for_continue or not choices.visible:
		return

	var question: Dictionary = QUESTIONS[question_index]
	var is_correct := option == int(question["answer"])
	question_index += 1
	if not is_correct:
		mistakes += 1

	choice_box.hide()
	choices.hide()
	_update_hud()

	if mistakes >= MAX_MISTAKES:
		_finish_failed_call()
	elif question_index >= QUESTIONS.size():
		_finish_successful_call()
	else:
		_show_pages([CORRECT_FEEDBACK if is_correct else WRONG_FEEDBACK], "next_question")

func _finish_successful_call() -> void:
	var game_state := _game_state()
	var stamina_cost := 5 + mistakes * 4
	var new_stamina := clampi(int(game_state.get("stamina")) - stamina_cost, 0, 100)
	game_state.call("complete_cra_call", new_stamina)
	_update_hud()
	_show_pages(SUCCESS_PAGES, "return_map")

func _finish_failed_call() -> void:
	var game_state := _game_state()
	var new_stamina := clampi(int(game_state.get("stamina")) - 12, 0, 100)
	game_state.call("record_failed_cra_call", new_stamina)
	_update_hud()
	_show_pages([FAILURE_TEXT], "return_map")

func _show_pages(pages: Array, next_action: String) -> void:
	result_pages = pages
	result_page_index = 0
	pending_action = next_action
	_set_result_layout()
	_set_dialogue_text(result_pages[result_page_index])
	choice_box.hide()
	choices.hide()
	waiting_for_continue = true
	prompt.text = "Press E to continue" if result_page_index < result_pages.size() - 1 or pending_action == "next_question" else "Press E to open map"
	prompt.show()

func _advance_continue() -> void:
	if result_page_index < result_pages.size() - 1:
		result_page_index += 1
		_set_result_layout()
		_set_dialogue_text(result_pages[result_page_index])
		prompt.text = "Press E to continue" if result_page_index < result_pages.size() - 1 or pending_action == "next_question" else "Press E to open map"
		prompt.show()
		return

	match pending_action:
		"next_question":
			_show_question()
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
	top_hud_text.text = "CRA CALL      Question %d/%d      Warnings %d/%d" % [
		mini(question_index + 1, QUESTIONS.size()),
		QUESTIONS.size(),
		mistakes,
		MAX_MISTAKES,
	]
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
