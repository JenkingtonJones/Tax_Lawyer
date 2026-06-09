extends Node2D

const GAME_STATE_SCRIPT := preload("res://scripts/GameState.gd")
const PLAYER_SPEED := 230.0
const PLAYER_FRAME_SCALE := Vector2(0.23, 0.23)
const WALK_MIN := Vector2(50, 92)
const WALK_MAX := Vector2(1230, 604)
const STREET_SCENE_PATH := "res://scenes/MainStreet.tscn"
const OFFICE_SCENE_PATH := "res://scenes/OfficeIntake.tscn"
const SPAWN_POINTS := {
	"law_office": Vector2(234, 318),
	"tax_office": Vector2(548, 284),
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
				get_tree().change_scene_to_file(OFFICE_SCENE_PATH)
			else:
				prompt.text = "Law office: appointment needed"
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
	current_location = "LawOffice" if spawn_key == "law_office" else "TaxOffice"
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
		_:
			prompt.hide()
			return

	prompt.show()

func _office_available() -> bool:
	var game_state := _game_state()
	return bool(game_state.get("office_unlocked")) or bool(game_state.get("office_completed"))

func _update_hud_hint() -> void:
	var game_state := _game_state()
	hud_hint.text = "Money $%d      Clients %d/5      Risk %s" % [
		int(game_state.get("money")),
		int(game_state.get("clients_completed")),
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
