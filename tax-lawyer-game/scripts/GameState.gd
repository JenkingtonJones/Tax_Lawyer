extends Node

var money := 850
var stamina := 100
var score := 1450
var audit_risk := 50
var clients_completed := 0
var client_resolved := false
var office_unlocked := false
var office_completed := false
var cra_guidance_requested := false
var cra_call_completed := false
var gelato_labs_unlocked := false
var cra_meeting_scheduled := false
var meaning_of_case_unlocked := false
var powder_lab_completed := false
var import_warehouse_unlocked := false
var warehouse_evidence_completed := false
var tribunal_unlocked := false
var meaning_of_case_completed := false
var case_wrap_up_pending := false
var map_spawn := "tax_office"

func save_street_state(new_money: int, new_stamina: int, new_audit_risk: int, new_clients_completed: int, resolved: bool) -> void:
	if resolved and not client_resolved:
		score += 175
	money = new_money
	stamina = new_stamina
	audit_risk = new_audit_risk
	clients_completed = new_clients_completed
	client_resolved = resolved

func start_cra_guidance_quest() -> void:
	if not cra_guidance_requested:
		score += 50
	office_unlocked = true
	cra_guidance_requested = true
	map_spawn = "tax_office"

func complete_cra_call(new_stamina: int) -> void:
	if not cra_call_completed:
		score += 125
	stamina = new_stamina
	cra_call_completed = true
	gelato_labs_unlocked = true
	map_spawn = "law_office"

func record_failed_cra_call(new_stamina: int) -> void:
	stamina = new_stamina
	map_spawn = "law_office"

func schedule_cra_guidance_meeting(new_stamina: int) -> void:
	if not cra_meeting_scheduled:
		score += 100
	stamina = new_stamina
	cra_meeting_scheduled = true
	map_spawn = "tax_office"

func unlock_meaning_of_case() -> void:
	if not meaning_of_case_unlocked:
		score += 75
	meaning_of_case_unlocked = true

func complete_powder_lab(new_stamina: int) -> void:
	if not powder_lab_completed:
		score += 200
	stamina = new_stamina
	powder_lab_completed = true
	import_warehouse_unlocked = true
	map_spawn = "gelato_labs"

func complete_warehouse_investigation(new_stamina: int) -> void:
	if not warehouse_evidence_completed:
		score += 250
	stamina = new_stamina
	warehouse_evidence_completed = true
	tribunal_unlocked = true
	map_spawn = "import_warehouse"

func complete_meaning_of_case() -> void:
	if meaning_of_case_completed:
		return

	score += 600
	money += 260
	stamina = clampi(stamina - 6, 0, 100)
	audit_risk = clampi(audit_risk - 12, 0, 100)
	clients_completed = clampi(clients_completed + 1, 0, 5)
	meaning_of_case_completed = true
	case_wrap_up_pending = true
	map_spawn = "tribunal"

func start_next_workday() -> void:
	client_resolved = false
	office_unlocked = false
	office_completed = false
	cra_guidance_requested = false
	cra_call_completed = false
	gelato_labs_unlocked = false
	cra_meeting_scheduled = false
	meaning_of_case_unlocked = false
	powder_lab_completed = false
	import_warehouse_unlocked = false
	warehouse_evidence_completed = false
	tribunal_unlocked = false
	meaning_of_case_completed = false
	case_wrap_up_pending = false
	stamina = mini(100, stamina + 25)
	map_spawn = "tax_office"
