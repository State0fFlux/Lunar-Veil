extends Node

const SAVE_PATH = "res://savegame.bin"

func saveGame():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data: Dictionary = {
		"health": Stats.health,
		"max_health": Stats.max_health,
		"mana": Stats.mana,
		"max_mana": Stats.max_mana,
		"powers_enabled": Stats.powers_enabled,
		"mana_regeneration_rate": Stats.mana_regeneration_rate,
		"mana_depletion_rate": Stats.mana_depletion_rate,
		"shadow_charge": Stats.shadow_charge,
		"powers": Magic.powers,
	}
	var jstr = JSON.stringify(data)
	file.store_line(jstr)
	
func loadGame():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if FileAccess.file_exists(SAVE_PATH):
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				Stats.health = current_line["health"]
				Stats.mana = current_line["mana"]
				Stats.mana_depletion_rate = current_line["mana_depletion_rate"]
				Stats.mana_regeneration_rate = current_line["mana_regeneration_rate"]
				Stats.max_health = current_line["max_health"]
				Stats.max_mana = current_line["max_mana"]
				Magic.powers = current_line["powers"]
				Stats.powers_enabled = current_line["powers_enabled"]
				Stats.shadow_charge = current_line["shadow_charge"]
				
				
