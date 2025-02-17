extends CharacterBody2D

const SPEED = 305.0

var chase = false
var direction: Vector2 = Vector2(0,0)
var attacking = false
var target_position: Vector2

@onready var player = $"../../Flux"
@onready var player_hitbox = $"../../Flux/Hitbox"
@onready var player_feet = $"../../Flux/Feet"
@onready var sprite = $AnimatedSprite2D
@onready var attack_range = $AttackRange
@onready var detection_range = $DetectionRange
@onready var navigation_agent = $NavigationAgent2D
@onready var feet = $Feet
@onready var vision = $Vision

func _ready() -> void:
	sprite.play("Idle")
	
func _process(delta: float) -> void:
	vision.target_position = (player_feet.global_position - vision.global_position)
	if detection_range.overlaps_area(player_hitbox):
		if not player.current_form == Stats.Form.SHADOW and vision.get_collider() == player:
			chase = true
	else:
		chase = false

func _physics_process(delta: float) -> void:
	if chase:
		navigation_agent.target_position = player_feet.global_position
		var direction = (navigation_agent.get_next_path_position() - feet.global_position).normalized()
		velocity = direction * SPEED
		if attacking:
			velocity = direction * SPEED * .75
		else:
			# Finding player
			sprite.play("Walk")
			if attack_range.overlaps_area(player_hitbox):
				player.take_damage(10)
				attackPlayer()
				await sprite.animation_finished
				attacking = false

	else:
		sprite.play("Idle")
		velocity = Vector2.ZERO
	if velocity.x < 0 and sprite.scale.x > 0 or velocity.x > 0 and sprite.scale.x < 0:
		print("Betta flip!")
		sprite.scale.x *= -1
	move_and_slide();

func attackPlayer():
	attacking = true
	sprite.play("Attack")
