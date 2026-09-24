extends Node2D

const GAME_STATE_SCRIPT := preload("res://scripts/GameState.gd")
const HOME_GRID_SCENE_PATH := "res://scenes/HomeGrid.tscn"

@onready var summary: Label = $UI/Summary
@onready var status: Label = $UI/Header/Status
@onready var continue_button: Button = $UI/ContinueButton

func _ready() -> void:
	var game_state := _game_state()
	summary.text = "The Meaning of 'Of' decision is signed and safely in the client file.\nThe fee has moved into escrow. Tomorrow's first appointment is already waiting."
	status.text = "SCORE %06d    ESCROW $%d    COFFEE %d%%    CLIENTS %d/5" % [
		int(game_state.get("score")),
		int(game_state.get("money")),
		int(game_state.get("stamina")),
		int(game_state.get("clients_completed")),
	]
	continue_button.pressed.connect(_start_next_workday)
	continue_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_start_next_workday()

func _start_next_workday() -> void:
	_game_state().call("start_next_workday")
	get_tree().change_scene_to_file(HOME_GRID_SCENE_PATH)

func _game_state() -> Node:
	var root := get_tree().root
	if root.has_node("GameState"):
		return root.get_node("GameState")

	var game_state: Node = GAME_STATE_SCRIPT.new()
	game_state.name = "GameState"
	root.add_child(game_state)
	return game_state
