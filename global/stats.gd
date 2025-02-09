extends Node

# Forms
enum Form { HUMAN, SHADOW }

# Player stats
var health = 100
var max_health = 100

var mana = 75
var max_mana = 75

var powers_enabled = true

# Ability settings
var mana_regeneration_rate = 2
var mana_depletion_rate = 20

# Shadow step settings
var shadow_charge = 1 # Time in seconds to hold W before switching forms
