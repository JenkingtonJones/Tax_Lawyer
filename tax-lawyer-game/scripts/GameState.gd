extends Node

var money := 850
var stamina := 100
var audit_risk := 50
var clients_completed := 0
var client_resolved := false
var office_unlocked := false
var office_completed := false
var map_spawn := "tax_office"

func save_street_state(new_money: int, new_stamina: int, new_audit_risk: int, new_clients_completed: int, resolved: bool) -> void:
	money = new_money
	stamina = new_stamina
	audit_risk = new_audit_risk
	clients_completed = new_clients_completed
	client_resolved = resolved
