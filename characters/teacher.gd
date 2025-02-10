extends CharacterBody2D

const SPEED = 350.0

var chase = false
var direction: Vector2 = Vector2(0,0)
var attacking = false

@onready var player = $"../../Player/Flux"
@onready var sprite = $AnimatedSprite2D
@onready var attack_range = $AttackRange
@onready var detection_range = $DetectionRange

func _ready() -> void:
	sprite.play("Idle")
	
func _process(delta: float) -> void:
	if detection_range.overlaps_body(player):
		if not player.current_form == Stats.Form.SHADOW:
			chase = true
	else:
		chase = false

func _physics_process(delta: float) -> void:
	direction = (player.position - self.position).normalized()
	if chase:
		if attacking:
			velocity.x = direction.x * SPEED * .75
		else:
			# Finding player
			sprite.play("Walk")
			velocity.x = direction.x * SPEED
			if attack_range.overlaps_body(player):
				player.take_damage(10)
				attackPlayer()
				await sprite.animation_finished
				attacking = false

	else:
		sprite.play("Idle")
		velocity.x = 0
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if direction.x < 0 and sprite.scale.x > 0 or direction.x > 0 and sprite.scale.x < 0:
		sprite.scale.x *= -1
	move_and_slide();

func attackPlayer():
	attacking = true
	sprite.play("Attack")
