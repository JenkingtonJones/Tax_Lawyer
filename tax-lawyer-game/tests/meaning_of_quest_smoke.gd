extends SceneTree

var failures := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var game_state := get_root().get_node("GameState")
	_reset_state(game_state)
	game_state.set("client_resolved", false)
	game_state.set("meaning_of_case_unlocked", false)
	var street := await _add_scene("res://scenes/MainStreet.tscn")
	street.call("_complete_cra_guidance_delivery")
	_check(bool(game_state.get("client_resolved")), "CRA delivery should resolve the elderly client")
	_check(bool(game_state.get("meaning_of_case_unlocked")), "CRA delivery should unlock the Meaning of 'Of' case")
	await create_timer(1.1).timeout
	await _remove_scene(street)

	_reset_state(game_state)
	game_state.call("unlock_meaning_of_case")
	var map_scene := await _add_scene("res://scenes/HomeGrid.tscn")
	_check(map_scene.call("_gelato_scene_path") == "res://scenes/PowderLab.tscn", "Gelato Labs should route to the powder lab")
	_check(map_scene.get_node("WorldBlockers").get_child_count() == 12, "City map should have 12 visible-world blockers")
	_check(map_scene.get_node("Locations").get_child_count() == 5, "City map should expose five active locations")
	_check(map_scene.get("active_target") == "GelatoLabs", "Only Gelato Labs should be the active map destination")
	_assert_single_visible_marker(map_scene, "GelatoLabs")
	await physics_frame
	_assert_map_locations_reachable(map_scene)
	_assert_open_road_probes(map_scene)
	await _assert_vertical_street_movement(map_scene)
	await _remove_scene(map_scene)

	var powder_lab := await _add_scene("res://scenes/PowderLab.tscn")
	powder_lab.call("_show_question", "StationA")
	powder_lab.call("_select_choice", 1)
	_check(powder_lab.get("completed_stations").is_empty(), "A wrong lab answer must not complete its station")
	powder_lab.call("_advance_continue")
	_answer_station(powder_lab, "StationA", 2)
	_answer_station(powder_lab, "StationB", 1)
	_answer_station(powder_lab, "StationC", 3)
	powder_lab.call("_open_npc_dialogue")
	_check(bool(game_state.get("powder_lab_completed")), "Completing lab evidence should finish the powder stage")
	_check(bool(game_state.get("import_warehouse_unlocked")), "Completing lab evidence should unlock the warehouse")
	await _remove_scene(powder_lab)

	map_scene = await _add_scene("res://scenes/HomeGrid.tscn")
	_check(bool(map_scene.call("_import_warehouse_available")), "Import Warehouse should be available on the map")
	_check(map_scene.get("active_target") == "ImportWarehouse", "Warehouse should become the sole active destination")
	_assert_single_visible_marker(map_scene, "ImportWarehouse")
	await _remove_scene(map_scene)

	var warehouse := await _add_scene("res://scenes/ImportWarehouse.tscn")
	_answer_station(warehouse, "StationA", 3)
	_answer_station(warehouse, "StationB", 2)
	_answer_station(warehouse, "StationC", 1)
	warehouse.call("_open_npc_dialogue")
	_check(bool(game_state.get("warehouse_evidence_completed")), "Completing shipment evidence should finish the warehouse stage")
	_check(bool(game_state.get("tribunal_unlocked")), "Completing shipment evidence should unlock the Tribunal")
	await _remove_scene(warehouse)

	map_scene = await _add_scene("res://scenes/HomeGrid.tscn")
	_check(bool(map_scene.call("_tribunal_available")), "Tribunal should be available on the map")
	_check(map_scene.get("active_target") == "Tribunal", "Tribunal should become the sole active destination")
	_assert_single_visible_marker(map_scene, "Tribunal")
	await _remove_scene(map_scene)

	var tribunal := await _add_scene("res://scenes/MeaningOfTribunal.tscn")
	tribunal.call("_show_round")
	tribunal.call("_select_choice", 1)
	_check(tribunal.get("current_round") == 0, "A wrong Tribunal answer must repeat the round")
	tribunal.call("_advance_continue")
	tribunal.call("_select_choice", 2)
	tribunal.call("_advance_continue")
	tribunal.call("_select_choice", 1)
	tribunal.call("_advance_continue")
	tribunal.call("_select_choice", 3)
	_check(bool(game_state.get("meaning_of_case_completed")), "The third correct argument should complete the case")
	_check(game_state.get("money") == 1110, "The decision should award a $260 fee")
	_check(game_state.get("clients_completed") == 1, "The decision should add one completed matter")
	_check(game_state.get("audit_risk") == 40, "One wrong argument and the decision should leave risk at 40")
	_check(game_state.get("score") == 2575, "Major Meaning of 'Of' milestones should increase score")
	await _remove_scene(tribunal)

	map_scene = await _add_scene("res://scenes/HomeGrid.tscn")
	_check(map_scene.get("active_target") == "LawOffice", "A completed case should route the player to filing")
	_check(map_scene.call("_office_scene_path") == "res://scenes/CaseWrapUp.tscn", "Law Office should open the case wrap-up")
	_assert_single_visible_marker(map_scene, "LawOffice")
	await _remove_scene(map_scene)

	var completed_money := int(game_state.get("money"))
	var completed_score := int(game_state.get("score"))
	var completed_clients := int(game_state.get("clients_completed"))
	var wrap_up := await _add_scene("res://scenes/CaseWrapUp.tscn")
	wrap_up.call("_start_next_workday")
	await process_frame
	_check(not bool(game_state.get("case_wrap_up_pending")), "Filing should clear the wrap-up objective")
	_check(not bool(game_state.get("meaning_of_case_completed")), "The next workday should reset the story chain")
	_check(game_state.get("money") == completed_money, "Starting a new day should preserve escrow")
	_check(game_state.get("score") == completed_score, "Starting a new day should preserve score")
	_check(game_state.get("clients_completed") == completed_clients, "Starting a new day should preserve completed clients")
	_check(game_state.get("map_spawn") == "tax_office", "The next workday should begin at the client office")
	var next_day_map := get_current_scene()
	if next_day_map == null or not next_day_map.has_method("_objective_info"):
		next_day_map = await _add_scene("res://scenes/HomeGrid.tscn")
	_check(next_day_map.get("active_target") == "TaxOffice", "A new workday should immediately provide a destination")
	_assert_single_visible_marker(next_day_map, "TaxOffice")
	await _remove_scene(next_day_map)

	if failures > 0:
		print("Meaning of 'Of' quest smoke test failed with %d checks" % failures)
		quit(1)
		return
	print("Meaning of 'Of' quest smoke test passed")
	quit(0)

func _answer_station(scene: Node, station_id: String, option: int) -> void:
	scene.call("_show_question", station_id)
	scene.call("_select_choice", option)
	scene.call("_advance_continue")

func _add_scene(path: String) -> Node:
	var scene: Node = load(path).instantiate()
	get_root().add_child(scene)
	await process_frame
	return scene

func _remove_scene(scene: Node) -> void:
	scene.queue_free()
	await process_frame

func _assert_map_locations_reachable(map_scene: Node2D) -> void:
	const GRID_STEP := 8
	const GRID_ORIGIN := Vector2(12, 96)
	const GRID_SIZE := Vector2i(158, 64)
	var goals := {
		"law_office": Vector2(160, 238),
		"tax_office": Vector2(500, 238),
		"gelato_labs": Vector2(151, 558),
		"import_warehouse": Vector2(500, 558),
		"tribunal": Vector2(1080, 238),
	}
	var reached: Dictionary = {}
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, 12)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collision_mask = 1
	query.collide_with_areas = false
	query.exclude = [map_scene.get_node("Player").get_rid()]
	var space_state := map_scene.get_world_2d().direct_space_state

	var start := Vector2i(
		roundi((goals["tax_office"].x - GRID_ORIGIN.x) / GRID_STEP),
		roundi((goals["tax_office"].y - GRID_ORIGIN.y) / GRID_STEP)
	)
	var queue: Array[Vector2i] = [start]
	var visited := {start: true}
	var cursor := 0
	var directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

	while cursor < queue.size() and reached.size() < goals.size():
		var cell := queue[cursor]
		cursor += 1
		var point := GRID_ORIGIN + Vector2(cell * GRID_STEP)
		for goal_name in goals:
			if point.distance_to(goals[goal_name]) <= GRID_STEP * 1.5:
				reached[goal_name] = true

		for direction in directions:
			var next_cell: Vector2i = cell + direction
			if next_cell.x < 0 or next_cell.y < 0 or next_cell.x >= GRID_SIZE.x or next_cell.y >= GRID_SIZE.y:
				continue
			if visited.has(next_cell):
				continue
			visited[next_cell] = true
			var next_point := GRID_ORIGIN + Vector2(next_cell * GRID_STEP)
			query.transform = Transform2D(0.0, next_point)
			if space_state.intersect_shape(query, 1).is_empty():
				queue.append(next_cell)

	_check(reached.size() == goals.size(), "Map entrances not reachable: %s" % [goals.keys().filter(func(key): return not reached.has(key))])

func _assert_open_road_probes(map_scene: Node2D) -> void:
	var probes := [
		Vector2(240, 250), Vector2(470, 250), Vector2(680, 250), Vector2(950, 250),
		Vector2(240, 410), Vector2(460, 410), Vector2(680, 410), Vector2(930, 410),
		Vector2(240, 580), Vector2(680, 580), Vector2(990, 580),
		Vector2(300, 330), Vector2(555, 330), Vector2(890, 330), Vector2(1200, 330),
	]
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, 12)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collision_mask = 1
	query.collide_with_areas = false
	query.exclude = [map_scene.get_node("Player").get_rid()]
	var space_state := map_scene.get_world_2d().direct_space_state
	for point in probes:
		query.transform = Transform2D(0.0, point)
		_check(space_state.intersect_shape(query, 1).is_empty(), "Visible road unexpectedly blocked at %s" % point)

func _assert_vertical_street_movement(map_scene: Node2D) -> void:
	var player := map_scene.get_node("Player") as CharacterBody2D
	player.position = Vector2(555, 296)
	var start_y := player.position.y
	Input.action_press("ui_down")
	for frame in range(8):
		await physics_frame
	Input.action_release("ui_down")
	_check(player.position.y > start_y + 12.0, "Player should move down the visible north-south street")

	var lower_y := player.position.y
	Input.action_press("ui_up")
	for frame in range(8):
		await physics_frame
	Input.action_release("ui_up")
	_check(player.position.y < lower_y - 12.0, "Player should move up the visible north-south street")

func _assert_single_visible_marker(map_scene: Node2D, expected_name: String) -> void:
	var visible_markers: Array[String] = []
	for marker in map_scene.get_node("LocationMarkers").get_children():
		if marker.visible:
			visible_markers.append(str(marker.name))
	if expected_name == "":
		_check(visible_markers.is_empty(), "No destination marker should be visible: %s" % [visible_markers])
	else:
		_check(visible_markers == [expected_name], "Only %s should be highlighted: %s" % [expected_name, visible_markers])

func _check(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)

func _reset_state(game_state: Node) -> void:
	game_state.set("money", 850)
	game_state.set("stamina", 100)
	game_state.set("score", 1450)
	game_state.set("audit_risk", 50)
	game_state.set("clients_completed", 0)
	game_state.set("client_resolved", true)
	game_state.set("office_unlocked", true)
	game_state.set("office_completed", true)
	game_state.set("cra_guidance_requested", true)
	game_state.set("cra_call_completed", true)
	game_state.set("gelato_labs_unlocked", true)
	game_state.set("cra_meeting_scheduled", true)
	game_state.set("meaning_of_case_unlocked", false)
	game_state.set("powder_lab_completed", false)
	game_state.set("import_warehouse_unlocked", false)
	game_state.set("warehouse_evidence_completed", false)
	game_state.set("tribunal_unlocked", false)
	game_state.set("meaning_of_case_completed", false)
	game_state.set("case_wrap_up_pending", false)
	game_state.set("map_spawn", "tax_office")
