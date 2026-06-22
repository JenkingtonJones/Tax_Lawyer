extends Node

var money := 850
var stamina := 100
var audit_risk := 50
var clients_completed := 0
var client_resolved := false
var office_unlocked := false
var office_completed := false
var cra_guidance_requested := false
var cra_call_completed := false
var gelato_labs_unlocked := false
var cra_meeting_scheduled := false
var map_spawn := "tax_office"

func save_street_state(new_money: int, new_stamina: int, new_audit_risk: int, new_clients_completed: int, resolved: bool) -> void:
	money = new_money
	stamina = new_stamina
	audit_risk = new_audit_risk
	clients_completed = new_clients_completed
	client_resolved = resolved

func start_cra_guidance_quest() -> void:
	office_unlocked = true
	cra_guidance_requested = true
	map_spawn = "tax_office"

func complete_cra_call(new_stamina: int) -> void:
	stamina = new_stamina
	cra_call_completed = true
	gelato_labs_unlocked = true
	map_spawn = "law_office"

func record_failed_cra_call(new_stamina: int) -> void:
	stamina = new_stamina
	map_spawn = "law_office"

func schedule_cra_guidance_meeting(new_stamina: int) -> void:
	stamina = new_stamina
	cra_meeting_scheduled = true
	map_spawn = "tax_office"
