extends Node2D

const PLAYER_SPEED := 235.0
const WALK_LEFT_LIMIT := 82.0
const WALK_RIGHT_LIMIT := 1198.0
const PLAYER_FLOOR_Y := 540.0
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

const CASE_CONFIGS := {
	"powder_lab": {
		"title": "GELATO LABS      Meaning of 'Of'",
		"objective": "Inspect the sample, formula, and production notes",
		"npc_name": "Dr. Affogato",
		"intro_pages": [
			"Dr. Affogato: Customs saw milk solids in the formula and stopped reading. The product has suffered from that level of confidence ever since.",
			"Inspect the ingredient sample, the production record, and the intended-use notes. Then bring me a theory that survives contact with the powder.",
		],
		"complete_pages": [
			"Dr. Affogato closes the formula binder. The powder contains milk, but it was not made by reducing milk. It was built as a multi-ingredient dessert base.",
			"A biscuit can contain milk too. The statute does not classify the biscuit by emotional proximity to a cow.",
			"The import documents should show what actually crossed the border. Follow the shipment to the Import Warehouse.",
		],
		"stations": {
			"StationA": {
				"label": "ingredient sample",
				"prompt": "Milk solids are 18% of the formula. What does that prove by itself?",
				"choices": [
					"It is legally milk; the percentage sign settles it.",
					"Only that milk is an ingredient; classify the product as a whole.",
					"Any powder near a cow belongs in a dairy heading.",
				],
				"answer": 2,
				"success": "You record the 18% figure without promoting it to a legal conclusion. The remaining 82% looks relieved.",
				"wrong": "Dr. Affogato taps the jar. Ingredient presence is evidence, not a complete classification test.",
			},
			"StationB": {
				"label": "production record",
				"prompt": "Which manufacturing fact matters most?",
				"choices": [
					"Sugar, starch, and flavouring are blended before milk solids are added.",
					"Dehydrated milk eventually learned pistachio.",
					"The mixer has a dairy-adjacent serial number.",
				],
				"answer": 1,
				"success": "The batch record describes an assembled preparation, not milk reduced into powder. Manufacturing has entered the chat reluctantly.",
				"wrong": "The machine's biography is not the product's production method. Read the batch sequence again.",
			},
			"StationC": {
				"label": "intended-use notes",
				"prompt": "How is the imported powder actually used?",
				"choices": [
					"It is served as a milk beverage at room temperature.",
					"It remains sealed for ceremonial customs purposes.",
					"It is measured into water and fat to produce flavoured gelato.",
				],
				"answer": 3,
				"success": "The use notes call it a gelato base. Nobody, including the powder, expected it to be a glass of milk.",
				"wrong": "The test batch instructions are unusually clear. The powder is an input for gelato, not a finished dairy drink.",
			},
		},
	},
	"warehouse": {
		"title": "IMPORT WAREHOUSE      Shipment Record",
		"objective": "Reconcile the invoice, pallet label, and mixing sheet",
		"npc_name": "Martin Manifest",
		"intro_pages": [
			"Martin Manifest: We filed it under powder because everything in this warehouse is either powder or trying not to become powder.",
			"The commercial invoice, pallet label, and mixing sheet disagree just enough to employ counsel. Reconcile all three.",
		],
		"complete_pages": [
			"Martin signs the evidence list. The invoice describes a dessert preparation; the pallet identifies a lot; the mixing sheet explains what the lot becomes.",
			"He finds the original mixing sheet under a coffee mug. The ring is not a customs stamp, despite its confidence.",
			"The record is ready. The Tribunal has scheduled a hearing on the meaning of one very small word.",
		],
		"stations": {
			"StationA": {
				"label": "commercial invoice",
				"prompt": "Which invoice description best identifies the goods as imported?",
				"choices": [
					"Milk, but with administrative garnish.",
					"Three pallets of pale uncertainty.",
					"Flavoured dessert-base food preparation in powder form.",
				],
				"answer": 3,
				"success": "The commercial description treats the shipment as a prepared dessert base. The invoice has accidentally become useful.",
				"wrong": "The invoice uses a commercial product description, not a mood. Check the line item again.",
			},
			"StationB": {
				"label": "pallet label",
				"prompt": "What can the pallet label establish?",
				"choices": [
					"Its dairy tariff classification is final and binding.",
					"It links the sample to the shipment lot, but does not decide legal meaning.",
					"The strawberry drawing makes it fresh fruit.",
				],
				"answer": 2,
				"success": "Lot 47-B connects the lab sample to the imported pallets. A label can identify evidence without interpreting Parliament.",
				"wrong": "A warehouse label tracks goods. It does not receive an appointment to the bench.",
			},
			"StationC": {
				"label": "mixing sheet",
				"prompt": "What does the mixing sheet add to the record?",
				"choices": [
					"It confirms milk solids are one component added to a larger prepared blend.",
					"It proves coffee rings are official seals.",
					"It converts the warehouse into a dairy farm retroactively.",
				],
				"answer": 1,
				"success": "The production sequence matches the lab record. The coffee ring is preserved as an interesting aside and nothing more.",
				"wrong": "Martin moves the mug. Beneath it is a production sequence, not a new branch of seal law.",
			},
		},
	},
}

@export_enum("powder_lab", "warehouse") var investigation_id: String = "powder_lab"

var completed_stations: Dictionary = {}
var nearby_interactions: Array[String] = []
var pending_station := ""
var waiting_for_continue := false
var pending_action := ""
var result_pages: Array = []
var result_page_index := 0
var player_frozen := false
var vertical_velocity := 0.0
var is_jumping := false

@onready var player: CharacterBody2D = $World/Player
@onready var player_sprite: AnimatedSprite2D = $World/Player/Sprite
@onready var npc_interaction: Area2D = $World/NPC/InteractionArea
@onready var evidence: Node2D = $World/Evidence
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
	_update_hud()

	if _stage_already_completed():
		_show_pages(["This evidence stage is already complete. The map has the next destination."], "return_map")
	elif not _stage_is_unlocked():
		_show_pages(["There is no active evidence file here yet. Return to the map and follow the current objective."], "return_map")
	else:
		_refresh_prompt()

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
	npc_interaction.body_entered.connect(_on_interaction_entered.bind("NPC"))
	npc_interaction.body_exited.connect(_on_interaction_exited.bind("NPC"))
	for child in evidence.get_children():
		var area := child as Area2D
		if area == null:
			continue
		area.body_entered.connect(_on_interaction_entered.bind(str(area.name)))
		area.body_exited.connect(_on_interaction_exited.bind(str(area.name)))

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
		elif not player_frozen and not nearby_interactions.is_empty():
			_mark_input_handled()
			_open_interaction(nearby_interactions.back())
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

func _on_interaction_entered(body: Node2D, interaction_id: String) -> void:
	if body != player:
		return
	if not nearby_interactions.has(interaction_id):
		nearby_interactions.append(interaction_id)
	_refresh_prompt()

func _on_interaction_exited(body: Node2D, interaction_id: String) -> void:
	if body != player:
		return
	nearby_interactions.erase(interaction_id)
	_refresh_prompt()

func _open_interaction(interaction_id: String) -> void:
	player_frozen = true
	player.velocity = Vector2.ZERO
	prompt.hide()
	if interaction_id == "NPC":
		_open_npc_dialogue()
	elif completed_stations.has(interaction_id):
		var station := _station(interaction_id)
		_show_pages(["The %s is already recorded in the evidence list." % station["label"]], "resume")
	else:
		_show_question(interaction_id)

func _open_npc_dialogue() -> void:
	var config := _case_config()
	if completed_stations.size() < 3:
		_show_pages(config["intro_pages"], "resume")
		return

	_complete_investigation()
	_show_pages(config["complete_pages"], "return_map")

func _show_question(interaction_id: String) -> void:
	pending_station = interaction_id
	waiting_for_continue = false
	pending_action = ""
	var station := _station(interaction_id)
	_set_menu_layout()
	_set_dialogue_text(station["prompt"])
	_set_choice_texts(station["choices"])
	choice_box.show()
	choices.show()
	dialogue_panel.show()
	prompt.text = "Press 1, 2, or 3"
	prompt.show()
	choice_1.grab_focus()

func _select_choice(option: int) -> void:
	if waiting_for_continue or pending_station == "":
		return

	var station_id := pending_station
	var station := _station(station_id)
	pending_station = ""
	choice_box.hide()
	choices.hide()

	var game_state := _game_state()
	if option == int(station["answer"]):
		completed_stations[station_id] = true
		game_state.set("stamina", clampi(int(game_state.get("stamina")) - 1, 0, 100))
		_update_hud()
		_show_pages([station["success"]], "resume")
	else:
		game_state.set("stamina", clampi(int(game_state.get("stamina")) - 2, 0, 100))
		_update_hud()
		_show_pages([station["wrong"]], "resume")

func _complete_investigation() -> void:
	var game_state := _game_state()
	var stamina_cost := 2 if investigation_id == "powder_lab" else 3
	var new_stamina := clampi(int(game_state.get("stamina")) - stamina_cost, 0, 100)
	if investigation_id == "powder_lab":
		game_state.call("complete_powder_lab", new_stamina)
	else:
		game_state.call("complete_warehouse_investigation", new_stamina)
	_update_hud()

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
		"resume":
			_resume_exploration()
		"return_map":
			get_tree().change_scene_to_file(HOME_GRID_SCENE_PATH)

func _resume_exploration() -> void:
	dialogue_panel.hide()
	waiting_for_continue = false
	pending_action = ""
	player_frozen = false
	_refresh_prompt()

func _update_continue_prompt() -> void:
	if result_page_index < result_pages.size() - 1:
		prompt.text = "Press E to continue"
	elif pending_action == "return_map":
		prompt.text = "Press E to open map"
	else:
		prompt.text = "Press E to continue investigating"
	prompt.show()

func _refresh_prompt() -> void:
	if player_frozen:
		return
	if nearby_interactions.is_empty():
		prompt.text = "%s (%d/3)" % [_case_config()["objective"], completed_stations.size()]
	else:
		var interaction_id: String = nearby_interactions.back()
		if interaction_id == "NPC":
			prompt.text = "Press E: talk to %s" % _case_config()["npc_name"]
		else:
			prompt.text = "Press E: inspect %s" % _station(interaction_id)["label"]
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
	top_hud_text.text = "%s      Evidence %d/3" % [_case_config()["title"], completed_stations.size()]
	bottom_hud_text.text = "Money $%d      Stamina %d                         Audit Risk %s" % [
		int(game_state.get("money")),
		int(game_state.get("stamina")),
		_audit_label(),
	]

func _stage_is_unlocked() -> bool:
	if investigation_id == "powder_lab":
		return bool(_game_state().get("meaning_of_case_unlocked"))
	return bool(_game_state().get("import_warehouse_unlocked"))

func _stage_already_completed() -> bool:
	if investigation_id == "powder_lab":
		return bool(_game_state().get("powder_lab_completed"))
	return bool(_game_state().get("warehouse_evidence_completed"))

func _case_config() -> Dictionary:
	return CASE_CONFIGS[investigation_id]

func _station(interaction_id: String) -> Dictionary:
	return _case_config()["stations"][interaction_id]

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
