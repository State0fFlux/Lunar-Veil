extends CharacterBody2D

const SPEED = 305.0

var chase = true # false
var direction: Vector2 = Vector2(0,0)
var attacking = false
var target_position: Vector2

@onready var player = $"../../Flux"
@onready var player_hitbox = $"../../Flux/Hitbox"
@onready var sprite = $AnimatedSprite2D
@onready var attack_range = $AttackRange
@onready var detection_range = $DetectionRange
@onready var navigation_agent = $NavigationAgent2D

func _ready() -> void:
	sprite.play("Idle")
	
func _process(delta: float) -> void:
	if detection_range.overlaps_area(player_hitbox):
		print("gotcha!")
		if not player.current_form == Stats.Form.SHADOW:
			chase = true
	else:
		chase = false

func _physics_process(delta: float) -> void:
	if chase:
		navigation_agent.target_position = player.global_position
		var direction = (navigation_agent.get_next_path_position() - self.global_position).normalized()
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
		
	if direction.x < 0 and sprite.scale.x > 0 or direction.x > 0 and sprite.scale.x < 0:
		sprite.scale.x *= -1
	move_and_slide();

func attackPlayer():
	attacking = true
	sprite.play("Attack")
