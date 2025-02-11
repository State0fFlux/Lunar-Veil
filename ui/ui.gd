extends Control

# Declare references to the progress bars
@onready var health_bar = $Health
@onready var mana_bar = $Mana

@onready var player = $"../../Flux"
@onready var charge_bar = $Charge
@onready var power_image = $Charge/Power

func _ready():
	player.damage_taken.connect(flash_health)  # Connect signal
	# Set the initial values of health and mana
	update_bars()

func _process(delta):
	update_bars()

func update_bars():
	# Set the progress bars to reflect the current health and mana values
	health_bar.value = Stats.health
	mana_bar.value = Stats.mana
	
	# Adjust the transparency based on the mana value
	var current_color = mana_bar.modulate  # Get the current color of the mana bar
	if Stats.mana < Stats.mana_depletion_rate or not Stats.powers_enabled:
		mana_bar.modulate = Color(current_color.r, current_color.g, current_color.b, 0.5)
	else:
		# Reset the transparency to full opacity (alpha = 1)
		mana_bar.modulate = Color(current_color.r, current_color.g, current_color.b, 1)
		
	power_image.texture = load("res://art/icons/%s.png" % [Magic.current_power])
	
	if Magic.is_power_active:
		power_image.modulate = Color(0.143, 0.1135, 0.37)
	else:
		power_image.modulate = Color.WHITE_SMOKE
		
	# Update displayed power
	charge_bar.value = Magic.charge
	
	
func flash_health():
	var tween = get_tree().create_tween()
	var stylebox = health_bar.get_theme_stylebox("fill")
	
	# Increase shadow size quickly
	tween.tween_property(stylebox, "shadow_size", 30, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Decrease shadow size back to normal
	tween.tween_property(stylebox, "shadow_size", 0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	
