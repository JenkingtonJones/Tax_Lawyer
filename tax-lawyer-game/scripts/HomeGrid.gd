extends Node2D

const GAME_STATE_SCRIPT := preload("res://scripts/GameState.gd")
const PLAYER_SPEED := 230.0
const PLAYER_FRAME_SCALE := Vector2(0.23, 0.23)
const PLAYER_FEET_OFFSET := Vector2(0, 34)
const FEET_MIN := Vector2(12, 96)
const FEET_MAX := Vector2(1268, 600)
const STREET_SCENE_PATH := "res://scenes/MainStreet.tscn"
const OFFICE_SCENE_PATH := "res://scenes/OfficeIntake.tscn"
const CASE_WRAP_UP_SCENE_PATH := "res://scenes/CaseWrapUp.tscn"
const CRA_CALL_SCENE_PATH := "res://scenes/CRACall.tscn"
const GELATO_LABS_SCENE_PATH := "res://scenes/GelatoLabs.tscn"
const POWDER_LAB_SCENE_PATH := "res://scenes/PowderLab.tscn"
const IMPORT_WAREHOUSE_SCENE_PATH := "res://scenes/ImportWarehouse.tscn"
const MEANING_TRIBUNAL_SCENE_PATH := "res://scenes/MeaningOfTribunal.tscn"

const SPAWN_POINTS := {
	"law_office": Vector2(160, 204),
	"tax_office": Vector2(500, 204),
	"gelato_labs": Vector2(151, 524),
	"import_warehouse": Vector2(500, 524),
	"tribunal": Vector2(1080, 204),
}

const LOCATION_TITLES := {
	"LawOffice": "LAW OFFICE",
	"TaxOffice": "TAX OFFICE",
	"GelatoLabs": "GELATO LABS",
	"ImportWarehouse": "IMPORT WAREHOUSE",
	"Tribunal": "TRIBUNAL",
}

# Every collision polygon sits inside a clearly visible building, fence, or body of water.
# Open asphalt, sidewalks, intersections, and plazas deliberately have no hidden blockers.
const SOLID_REGIONS := {
	"LawOfficeBuilding": [
		Vector2(82, 88), Vector2(207, 88), Vector2(207, 202), Vector2(82, 202),
	],
	"TaxOfficeBuilding": [
		Vector2(405, 88), Vector2(590, 88), Vector2(590, 188), Vector2(405, 188),
	],
	"GroceryBuilding": [
		Vector2(725, 88), Vector2(845, 88), Vector2(845, 160), Vector2(725, 160),
	],
	"TribunalBuilding": [
		Vector2(1000, 88), Vector2(1170, 88), Vector2(1170, 187), Vector2(1000, 187),
	],
	"CoffeeBuilding": [
		Vector2(355, 285), Vector2(500, 285), Vector2(500, 367), Vector2(355, 367),
	],
	"PetChewsBuilding": [
		Vector2(640, 286), Vector2(830, 286), Vector2(830, 369), Vector2(640, 369),
	],
	"CustomsBuilding": [
		Vector2(970, 286), Vector2(1155, 286), Vector2(1155, 355), Vector2(970, 355),
	],
	"GelatoBuilding": [
		Vector2(82, 446), Vector2(211, 446), Vector2(211, 520), Vector2(82, 520),
	],
	"ImportWarehouseBuilding": [
		Vector2(375, 446), Vector2(650, 446), Vector2(650, 525), Vector2(375, 525),
	],
	"FreightYardFence": [
		Vector2(720, 458), Vector2(970, 458), Vector2(970, 604), Vector2(720, 604),
	],
	"NorthHarbourWater": [
		Vector2(1235, 96), Vector2(1280, 96), Vector2(1280, 390), Vector2(1235, 390),
	],
	"HarbourWater": [
		Vector2(1090, 408), Vector2(1280, 408), Vector2(1280, 608), Vector2(1060, 608),
		Vector2(1060, 540), Vector2(1074, 540), Vector2(1074, 460), Vector2(1090, 460),
	],
}

var current_location := ""
var active_target := ""
var marker_phase := 0.0
var location_markers: Dictionary = {}

@onready var player: CharacterBody2D = $Player
@onready var player_sprite: AnimatedSprite2D = $Player/Sprite
@onready var locations: Node2D = $Locations
@onready var world_blockers: Node2D = $WorldBlockers
@onready var marker_layer: Node2D = $LocationMarkers
@onready var prompt_panel: Panel = $UI/PromptPanel
@onready var prompt: Label = $UI/PromptPanel/Prompt
@onready var score_label: Label = $UI/TopBar/Score
@onready var active_file_label: Label = $UI/TopBar/ActiveFile
@onready var objective_label: Label = $UI/TopBar/Objective
@onready var escrow_label: Label = $UI/BottomBar/Escrow
@onready var coffee_label: Label = $UI/BottomBar/Coffee
@onready var coffee_bar: ProgressBar = $UI/BottomBar/CoffeeBar
@onready var risk_label: Label = $UI/BottomBar/Risk
@onready var clients_label: Label = $UI/BottomBar/Clients
@onready var next_location_label: Label = $UI/BottomBar/NextLocation

func _ready() -> void:
	_setup_animations()
	_setup_world_blockers()
	_connect_location_areas()
	_create_location_markers()
	active_target = str(_objective_info()["target"])
	_update_location_markers()
	player_sprite.play("idle")
	prompt_panel.hide()
	_place_player_at_spawn()
	_update_hud()

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	player.velocity = direction * PLAYER_SPEED
	player.move_and_slide()
	_clamp_player_to_visible_frame()
	player.z_index = int(player.position.y) + 10

	if direction.length() > 0.0:
		if absf(direction.x) > 0.05:
			player_sprite.flip_h = direction.x < 0.0
		player_sprite.play("walk")
	else:
		player_sprite.play("idle")

	marker_phase += delta
	_animate_active_marker()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or current_location == "" or current_location != active_target:
		return

	_mark_input_handled()
	match current_location:
		"TaxOffice":
			_game_state().set("map_spawn", "tax_office")
			get_tree().change_scene_to_file(STREET_SCENE_PATH)
		"LawOffice":
			_game_state().set("map_spawn", "law_office")
			get_tree().change_scene_to_file(_office_scene_path())
		"GelatoLabs":
			_game_state().set("map_spawn", "gelato_labs")
			get_tree().change_scene_to_file(_gelato_scene_path())
		"ImportWarehouse":
			_game_state().set("map_spawn", "import_warehouse")
			get_tree().change_scene_to_file(IMPORT_WAREHOUSE_SCENE_PATH)
		"Tribunal":
			_game_state().set("map_spawn", "tribunal")
			get_tree().change_scene_to_file(MEANING_TRIBUNAL_SCENE_PATH)

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

func _setup_world_blockers() -> void:
	for region_name in SOLID_REGIONS:
		var body := StaticBody2D.new()
		body.name = StringName(region_name)
		var collision := CollisionPolygon2D.new()
		collision.polygon = PackedVector2Array(SOLID_REGIONS[region_name])
		body.add_child(collision)
		world_blockers.add_child(body)

func _connect_location_areas() -> void:
	for child in locations.get_children():
		var area := child as Area2D
		if area == null:
			continue

		area.body_entered.connect(_on_location_body_entered.bind(area.name))
		area.body_exited.connect(_on_location_body_exited.bind(area.name))

func _create_location_markers() -> void:
	for child in locations.get_children():
		var area := child as Area2D
		if area == null:
			continue

		var marker := Node2D.new()
		marker.name = area.name
		marker.position = area.position + Vector2(0, -72)
		marker.visible = false
		marker_layer.add_child(marker)

		var panel := Panel.new()
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.position = Vector2(-105, -22)
		panel.size = Vector2(210, 34)
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color(0.025, 0.047, 0.062, 0.95)
		panel_style.border_width_left = 3
		panel_style.border_width_top = 3
		panel_style.border_width_right = 3
		panel_style.border_width_bottom = 3
		panel_style.border_color = Color(0.96, 0.72, 0.24, 1)
		panel_style.corner_radius_top_left = 4
		panel_style.corner_radius_top_right = 4
		panel_style.corner_radius_bottom_left = 4
		panel_style.corner_radius_bottom_right = 4
		panel.add_theme_stylebox_override("panel", panel_style)
		marker.add_child(panel)

		var label := Label.new()
		label.name = "Label"
		label.position = Vector2(6, 2)
		label.size = Vector2(198, 30)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color(0.98, 0.93, 0.78, 1))
		label.text = "NEXT: %s" % LOCATION_TITLES[str(area.name)]
		panel.add_child(label)

		var arrow := Polygon2D.new()
		arrow.position = Vector2(0, 12)
		arrow.polygon = PackedVector2Array([
			Vector2(-11, 0), Vector2(11, 0), Vector2(0, 16),
		])
		arrow.color = Color(0.98, 0.72, 0.2, 1)
		marker.add_child(arrow)
		location_markers[str(area.name)] = marker

func _update_location_markers() -> void:
	for location_name in location_markers:
		var marker := location_markers[location_name] as Node2D
		marker.visible = location_name == active_target and active_target != ""
		marker.scale = Vector2.ONE
		marker.modulate = Color.WHITE

func _animate_active_marker() -> void:
	if active_target == "" or not location_markers.has(active_target):
		return

	var marker := location_markers[active_target] as Node2D
	var pulse := 1.0 + sin(marker_phase * 4.0) * 0.035
	var alpha := 0.88 + sin(marker_phase * 4.0) * 0.12
	marker.scale = Vector2(pulse, pulse)
	marker.modulate = Color(1, 1, 1, alpha)

func _clamp_player_to_visible_frame() -> void:
	var feet := player.position + PLAYER_FEET_OFFSET
	feet.x = clampf(feet.x, FEET_MIN.x, FEET_MAX.x)
	feet.y = clampf(feet.y, FEET_MIN.y, FEET_MAX.y)
	player.position = feet - PLAYER_FEET_OFFSET

func _place_player_at_spawn() -> void:
	var spawn_key := str(_game_state().get("map_spawn"))
	if not SPAWN_POINTS.has(spawn_key):
		spawn_key = "tax_office"

	player.position = SPAWN_POINTS[spawn_key]
	var spawn_location := _location_name_for_spawn(spawn_key)
	current_location = spawn_location if spawn_location == active_target else ""
	_update_prompt()

func _location_name_for_spawn(spawn_key: String) -> String:
	match spawn_key:
		"law_office":
			return "LawOffice"
		"gelato_labs":
			return "GelatoLabs"
		"import_warehouse":
			return "ImportWarehouse"
		"tribunal":
			return "Tribunal"
		_:
			return "TaxOffice"

func _on_location_body_entered(body: Node2D, location_name: StringName) -> void:
	if body != player or str(location_name) != active_target:
		return

	current_location = str(location_name)
	_update_prompt()

func _on_location_body_exited(body: Node2D, location_name: StringName) -> void:
	if body != player or current_location != str(location_name):
		return

	current_location = ""
	prompt_panel.hide()

func _update_prompt() -> void:
	if current_location == "" or current_location != active_target:
		prompt_panel.hide()
		return

	prompt.text = "Press E: %s" % LOCATION_TITLES[current_location].capitalize()
	prompt_panel.show()

func _objective_info() -> Dictionary:
	var game_state := _game_state()
	if bool(game_state.get("case_wrap_up_pending")):
		return {"target": "LawOffice", "instruction": "FILE THE TRIBUNAL DECISION"}
	if _cra_call_needed():
		return {"target": "LawOffice", "instruction": "MAKE THE CRA GUIDANCE CALL"}
	if _cra_gelato_meeting_available():
		return {"target": "GelatoLabs", "instruction": "MEET THE CRA REPRESENTATIVE"}
	if bool(game_state.get("cra_meeting_scheduled")) and not bool(game_state.get("client_resolved")):
		return {"target": "TaxOffice", "instruction": "DELIVER GUIDANCE TO THE CLIENT"}
	if _powder_lab_available():
		return {"target": "GelatoLabs", "instruction": "INSPECT THE POWDER EVIDENCE"}
	if _import_warehouse_available():
		return {"target": "ImportWarehouse", "instruction": "TRACE THE IMPORT SHIPMENT"}
	if _tribunal_available():
		return {"target": "Tribunal", "instruction": "ARGUE THE MEANING OF OF"}
	if _receipt_follow_up_available():
		return {"target": "TaxOffice", "instruction": "REVIEW THE RECEIPT INTAKE"}
	if bool(game_state.get("office_unlocked")) and not bool(game_state.get("office_completed")) and not bool(game_state.get("cra_guidance_requested")):
		return {"target": "LawOffice", "instruction": "COMPLETE THE OFFICE INTAKE"}
	if not bool(game_state.get("client_resolved")):
		return {"target": "TaxOffice", "instruction": "RETURN TO THE CLIENT"}
	if bool(game_state.get("meaning_of_case_completed")):
		return {"target": "", "instruction": "CASE CLOSED - NEW MATTER PENDING"}
	return {"target": "", "instruction": "NO ACTIVE MATTER"}

func _update_hud() -> void:
	var game_state := _game_state()
	var objective := _objective_info()
	var coffee := int(game_state.get("stamina"))
	score_label.text = "SCORE %06d" % int(game_state.get("score"))
	escrow_label.text = "ESCROW  $%d" % int(game_state.get("money"))
	coffee_label.text = "COFFEE  %d%%" % coffee
	coffee_bar.value = coffee
	risk_label.text = "RISK  %s" % _audit_label().to_upper()
	clients_label.text = "CLIENTS  %d/5" % int(game_state.get("clients_completed"))
	active_file_label.text = _active_file_text()
	objective_label.text = "NEXT ACTION: %s" % objective["instruction"]
	if active_target == "":
		next_location_label.text = "DESTINATION\nNONE"
	else:
		next_location_label.text = "DESTINATION\n%s" % LOCATION_TITLES[active_target]

func _active_file_text() -> String:
	var game_state := _game_state()
	if bool(game_state.get("case_wrap_up_pending")):
		return "FILE: DECISION TO FILE"
	if bool(game_state.get("meaning_of_case_completed")):
		return "FILE: CLOSED"
	if bool(game_state.get("meaning_of_case_unlocked")):
		return 'FILE: MEANING OF "OF"'
	return "FILE: B2 AUDIT"

func _office_scene_path() -> String:
	if bool(_game_state().get("case_wrap_up_pending")):
		return CASE_WRAP_UP_SCENE_PATH
	return CRA_CALL_SCENE_PATH if _cra_call_needed() else OFFICE_SCENE_PATH

func _cra_call_needed() -> bool:
	var game_state := _game_state()
	return bool(game_state.get("cra_guidance_requested")) and not bool(game_state.get("cra_call_completed"))

func _receipt_follow_up_available() -> bool:
	var game_state := _game_state()
	return bool(game_state.get("office_completed")) and bool(game_state.get("client_resolved")) and not bool(game_state.get("cra_guidance_requested"))

func _cra_gelato_meeting_available() -> bool:
	var game_state := _game_state()
	return bool(game_state.get("gelato_labs_unlocked")) and not bool(game_state.get("cra_meeting_scheduled"))

func _powder_lab_available() -> bool:
	var game_state := _game_state()
	return bool(game_state.get("meaning_of_case_unlocked")) and not bool(game_state.get("powder_lab_completed"))

func _gelato_scene_path() -> String:
	return POWDER_LAB_SCENE_PATH if _powder_lab_available() else GELATO_LABS_SCENE_PATH

func _import_warehouse_available() -> bool:
	var game_state := _game_state()
	return bool(game_state.get("import_warehouse_unlocked")) and not bool(game_state.get("warehouse_evidence_completed"))

func _tribunal_available() -> bool:
	var game_state := _game_state()
	return bool(game_state.get("tribunal_unlocked")) and not bool(game_state.get("meaning_of_case_completed"))

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
