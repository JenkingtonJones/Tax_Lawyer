extends SceneTree

const OUTPUT_DIR := "/tmp/tax-lawyer-scene-captures"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
	var game_state := get_root().get_node("GameState")
	game_state.set("client_resolved", true)
	game_state.set("cra_guidance_requested", true)
	game_state.set("cra_call_completed", true)
	game_state.set("gelato_labs_unlocked", true)
	game_state.set("cra_meeting_scheduled", true)
	game_state.set("meaning_of_case_unlocked", true)
	game_state.set("import_warehouse_unlocked", true)
	game_state.set("tribunal_unlocked", true)

	await _capture("res://scenes/HomeGrid.tscn", "home_grid.png")
	await _capture("res://scenes/PowderLab.tscn", "powder_lab.png")
	await _capture("res://scenes/ImportWarehouse.tscn", "import_warehouse.png")
	await _capture("res://scenes/MeaningOfTribunal.tscn", "meaning_tribunal.png")
	game_state.set("meaning_of_case_completed", true)
	game_state.set("case_wrap_up_pending", true)
	await _capture("res://scenes/HomeGrid.tscn", "home_grid_filing.png")
	await _capture("res://scenes/CaseWrapUp.tscn", "case_wrap_up.png")
	await _capture_question("res://scenes/PowderLab.tscn", "powder_question.png", "StationA")
	await _capture_question("res://scenes/ImportWarehouse.tscn", "warehouse_question.png", "StationA")
	await _capture_question("res://scenes/MeaningOfTribunal.tscn", "tribunal_question.png")
	quit(0)

func _capture(scene_path: String, file_name: String) -> void:
	var scene: Node = load(scene_path).instantiate()
	get_root().add_child(scene)
	await process_frame
	await process_frame
	await process_frame
	var image := get_root().get_viewport().get_texture().get_image()
	var result := image.save_png(OUTPUT_DIR.path_join(file_name))
	assert(result == OK)
	scene.queue_free()
	await process_frame

func _capture_question(scene_path: String, file_name: String, station_id: String = "") -> void:
	var scene: Node = load(scene_path).instantiate()
	get_root().add_child(scene)
	await process_frame
	if station_id == "":
		scene.call("_show_round")
	else:
		scene.call("_show_question", station_id)
	await process_frame
	var image := get_root().get_viewport().get_texture().get_image()
	var result := image.save_png(OUTPUT_DIR.path_join(file_name))
	assert(result == OK)
	scene.queue_free()
	await process_frame
