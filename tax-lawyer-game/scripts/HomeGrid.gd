extends Node2D

const GAME_STATE_SCRIPT := preload("res://scripts/GameState.gd")
const PLAYER_SPEED := 230.0
const PLAYER_FRAME_SCALE := Vector2(0.23, 0.23)
const WALK_MIN := Vector2(50, 92)
const WALK_MAX := Vector2(1230, 604)
const STREET_SCENE_PATH := "res://scenes/MainStreet.tscn"
const OFFICE_SCENE_PATH := "res://scenes/OfficeIntake.tscn"
const CRA_CALL_SCENE_PATH := "res://scenes/CRACall.tscn"
const GELATO_LABS_SCENE_PATH := "res://scenes/GelatoLabs.tscn"
const POWDER_LAB_SCENE_PATH := "res://scenes/PowderLab.tscn"
const IMPORT_WAREHOUSE_SCENE_PATH := "res://scenes/ImportWarehouse.tscn"
const MEANING_TRIBUNAL_SCENE_PATH := "res://scenes/MeaningOfTribunal.tscn"
const SPAWN_POINTS := {
	"law_office": Vector2(294, 330),
	"tax_office": Vector2(566, 310),
	"gelato_labs": Vector2(320, 515),
	"import_warehouse": Vector2(648, 535),
	"tribunal": Vector2(1065, 315),
}

var current_location := ""

@onready var player: CharacterBody2D = $Player
@onready var player_sprite: AnimatedSprite2D = $Player/Sprite
@onready var locations: Node2D = $Locations
@onready var prompt: Label = $UI/Prompt
@onready var hud_hint: Label = $UI/HudHint

func _ready() -> void:
	_setup_animations()
	_connect_location_areas()
	player_sprite.play("idle")
	prompt.hide()
	_place_player_at_spawn()
	_update_hud_hint()

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	player.velocity = direction * PLAYER_SPEED
	player.move_and_slide()
	player.position.x = clampf(player.position.x, WALK_MIN.x, WALK_MAX.x)
	player.position.y = clampf(player.position.y, WALK_MIN.y, WALK_MAX.y)

	if direction.length() > 0.0:
		player_sprite.flip_h = direction.x < 0.0
		player_sprite.play("walk")
	else:
		player_sprite.play("idle")

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or current_location == "":
		return

	_mark_input_handled()
	match current_location:
		"TaxOffice":
			_game_state().set("map_spawn", "tax_office")
			get_tree().change_scene_to_file(STREET_SCENE_PATH)
		"LawOffice":
			if _office_available():
				_game_state().set("map_spawn", "law_office")
				get_tree().change_scene_to_file(_office_scene_path())
			else:
				prompt.text = "Law office: appointment needed"
				prompt.show()
		"GelatoLabs":
			if _gelato_labs_available():
				_game_state().set("map_spawn", "gelato_labs")
				get_tree().change_scene_to_file(_gelato_scene_path())
			else:
				prompt.text = _gelato_unavailable_text()
				prompt.show()
		"ImportWarehouse":
			if _import_warehouse_available():
				_game_state().set("map_spawn", "import_warehouse")
				get_tree().change_scene_to_file(IMPORT_WAREHOUSE_SCENE_PATH)
			else:
				prompt.text = "Import Warehouse: evidence lead locked"
				prompt.show()
		"Tribunal":
			if _tribunal_available():
				_game_state().set("map_spawn", "tribunal")
				get_tree().change_scene_to_file(MEANING_TRIBUNAL_SCENE_PATH)
			else:
				prompt.text = "Tribunal: no hearing scheduled"
				prompt.show()

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

func _connect_location_areas() -> void:
	for child in locations.get_children():
		var area := child as Area2D
		if area == null:
			continue

		area.body_entered.connect(_on_location_body_entered.bind(area.name))
		area.body_exited.connect(_on_location_body_exited.bind(area.name))

func _place_player_at_spawn() -> void:
	var spawn_key := str(_game_state().get("map_spawn"))
	if not SPAWN_POINTS.has(spawn_key):
		spawn_key = "tax_office"

	player.position = SPAWN_POINTS[spawn_key]
	match spawn_key:
		"law_office":
			current_location = "LawOffice"
		"gelato_labs":
			current_location = "GelatoLabs"
		"import_warehouse":
			current_location = "ImportWarehouse"
		"tribunal":
			current_location = "Tribunal"
		_:
			current_location = "TaxOffice"
	_update_prompt()

func _on_location_body_entered(body: Node2D, location_name: StringName) -> void:
	if body != player:
		return

	current_location = str(location_name)
	_update_prompt()

func _on_location_body_exited(body: Node2D, location_name: StringName) -> void:
	if body != player or current_location != str(location_name):
		return

	current_location = ""
	prompt.hide()

func _update_prompt() -> void:
	match current_location:
		"TaxOffice":
			prompt.text = "Press E: Tax Office street"
		"LawOffice":
			prompt.text = "Press E: Law Office" if _office_available() else "Law office: appointment needed"
		"GelatoLabs":
			prompt.text = "Press E: Gelato Labs" if _gelato_labs_available() else _gelato_unavailable_text()
		"ImportWarehouse":
			prompt.text = "Press E: Import Warehouse" if _import_warehouse_available() else "Import Warehouse: evidence lead locked"
		"Tribunal":
			prompt.text = "Press E: Tribunal" if _tribunal_available() else "Tribunal: no hearing scheduled"
		_:
			prompt.hide()
			return

	prompt.show()

func _office_available() -> bool:
	var game_state := _game_state()
	return bool(game_state.get("office_unlocked")) or bool(game_state.get("office_completed"))

func _office_scene_path() -> String:
	return CRA_CALL_SCENE_PATH if _cra_call_needed() else OFFICE_SCENE_PATH

func _cra_call_needed() -> bool:
	var game_state := _game_state()
	return bool(game_state.get("cra_guidance_requested")) and not bool(game_state.get("cra_call_completed"))

func _gelato_labs_available() -> bool:
	return _cra_gelato_meeting_available() or _powder_lab_available()

func _cra_gelato_meeting_available() -> bool:
	var game_state := _game_state()
	return bool(game_state.get("gelato_labs_unlocked")) and not bool(game_state.get("cra_meeting_scheduled"))

func _powder_lab_available() -> bool:
	var game_state := _game_state()
	return bool(game_state.get("meaning_of_case_unlocked")) and not bool(game_state.get("powder_lab_completed"))

func _gelato_scene_path() -> String:
	return POWDER_LAB_SCENE_PATH if _powder_lab_available() else GELATO_LABS_SCENE_PATH

func _gelato_unavailable_text() -> String:
	if bool(_game_state().get("powder_lab_completed")):
		return "Gelato Labs: evidence collected"
	return "Gelato Labs: no active appointment"

func _import_warehouse_available() -> bool:
	var game_state := _game_state()
	return bool(game_state.get("import_warehouse_unlocked")) and not bool(game_state.get("warehouse_evidence_completed"))

func _tribunal_available() -> bool:
	var game_state := _game_state()
	return bool(game_state.get("tribunal_unlocked")) and not bool(game_state.get("meaning_of_case_completed"))

func _update_hud_hint() -> void:
	var game_state := _game_state()
	var objective := "Return to client"
	if _cra_call_needed():
		objective = "CRA call: Law Office"
	elif _cra_gelato_meeting_available():
		objective = "Meet CRA: Gelato Labs"
	elif bool(game_state.get("cra_meeting_scheduled")) and not bool(game_state.get("client_resolved")):
		objective = "Tell client: Tax Office"
	elif _powder_lab_available():
		objective = "Inspect powder: Gelato Labs"
	elif _import_warehouse_available():
		objective = "Trace shipment: Import Warehouse"
	elif _tribunal_available():
		objective = "Argue wording: Tribunal"
	elif bool(game_state.get("meaning_of_case_completed")):
		objective = "Case won: Meaning of 'Of'"

	hud_hint.text = "Money $%d      Clients %d/5      Risk %s      %s" % [
		int(game_state.get("money")),
		int(game_state.get("clients_completed")),
		_audit_label(),
		objective,
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
