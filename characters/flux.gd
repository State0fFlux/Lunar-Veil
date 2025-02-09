extends CharacterBody2D

# Important for form shifts
var current_form: Stats.Form
var form_data: Object = null
var anim_prefix = "Human"

# Dynamic movement settings
var speed
var jump_velocity
var speed_mult = 1

signal damage_taken

@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var particles = $AnimatedSprite2D/ShadowParticles
@onready var invincibility = $InvincibilityTimer
@onready var ui = $"../../CanvasLayer/UI"

# add something to keep track:
# - health
#   - depletes when:
#     - in shadow form & exposed to light
#     - in human form & attacked by enemies
# - shadow meter
#   - depletes quickly when in shadow form
#   - cap is extended when in dark areas, limited in light areas
#   - replenish by finding tarot cards, prayer rooms, idrk something dark and celestial
	
func _ready():
	set_form(Stats.Form.HUMAN)  # Set form to HUMAN initially

func _process(delta):
	# managing death
	if Stats.health <= 0:
		queue_free()
		get_tree().change_scene_to_file("res://scenes/title.tscn")
			
	# managing magic form
	if Stats.mana <= 0 and not current_form == Stats.Form.HUMAN:
		# forced into human form
		Magic.charge = 0
		if Stats.mana <= 0:
			Stats.mana = 0
		set_form(Stats.Form.HUMAN)
	if Stats.powers_enabled:
		# if this is a charge power, like the BLASTER (range weapon) or SHADOW, or something else, then do this loading mechanic
		if Magic.charging and Stats.mana > Stats.mana_depletion_rate:
			Magic.charge += delta
			if Magic.charge >= Stats.shadow_charge and current_form == Stats.Form.HUMAN:
				# Note: should only happen if our current power is shadow, and not something else
				set_form(Stats.Form.SHADOW)  # Transform to shadow form
		if Stats.mana < Stats.max_mana and current_form == Stats.Form.HUMAN:
			# regenerate mana on an inverse curve
			var regen_factor = (0.0 + Stats.max_mana - Stats.mana) / Stats.max_mana  # Value between 0 and 1
			Stats.mana += delta * Stats.mana_regeneration_rate * regen_factor
			if Stats.mana > Stats.max_mana:  # Cap mana to max_mana
				Stats.mana = Stats.max_mana
	if current_form == Stats.Form.SHADOW or not invincibility.is_stopped():
		self.collision_mask &= ~2
	elif invincibility.is_stopped():
		self.collision_mask |= 2

func _input(event):
	if event.is_action_pressed("use_power") and Stats.mana > 0:  # W is pressed
		Magic.charging = true
		Magic.charge = 0.0  # Reset timer

	elif event.is_action_released("use_power"):  # W is released
		Magic.charging = false
		Magic.charge = 0.0  # Reset timer
		if current_form == Stats.Form.SHADOW:  # If in shadow form, revert back
			set_form(Stats.Form.HUMAN)
	
func set_form(new_form: Stats.Form):
	current_form = new_form
	match current_form:
		Stats.Form.HUMAN:
			Magic.is_power_active = false
			particles.emitting = false
			form_data = HumanForm.new()
		Stats.Form.SHADOW:
			Magic.is_power_active = true
			particles.emitting = true
			form_data = ShadowForm.new()    
	update_form_attributes()
	
func update_form_attributes():
	jump_velocity = form_data.jump_velocity
	speed = form_data.speed

func _physics_process(delta: float) -> void:
	# Check for current state (human or shadow)
	if current_form == Stats.Form.HUMAN:
		anim_prefix = "Human"
	elif current_form == Stats.Form.SHADOW:
		anim_prefix = "Shadow"
		Stats.mana -= delta * Stats.mana_depletion_rate
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction < 0:
		# walking to the left
		sprite.flip_h = true
	else:
		# walking to the right
		sprite.flip_h = false
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		anim.play(anim_prefix + "Jump")
	
	if direction:
		velocity.x = direction * speed * speed_mult
		if velocity.y == 0:
			anim.play(anim_prefix + "Walk")  # Plays "HumanWalk" or "ShadowWalk"
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if velocity.y == 0:
			anim.play(anim_prefix + "Idle")  # Plays "HumanIdle" or "ShadowIdle"
	if velocity.y > 0:
		anim.play(anim_prefix + "Fall")  # Plays "HumanFall" or "ShadowFall"
	elif velocity.y < 0:
		anim.play(anim_prefix + "Jump")  # Plays "HumanJump" or "ShadowJump"

	move_and_slide()
	
func take_damage(amount):
	damage_taken.emit()
	Stats.health -= amount
	Stats.powers_enabled = false
	speed_mult = 1.5
	invincibility.start(1)
	await invincibility.timeout
	speed_mult = 1
	Stats.powers_enabled = true
	
