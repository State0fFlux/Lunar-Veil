extends CharacterBody2D

const SPEED = 50.0

var chase = false
var direction: Vector2 = Vector2(0,0)
var attacking = false
var target_position: Vector2

@onready var player = $"../../Flux"
@onready var sprite = $AnimatedSprite2D
@onready var attack_range = $AttackRange
@onready var detection_range = $DetectionRange
@onready var navigation_agent = $NavigationAgent2D

func _ready() -> void:
	sprite.play("Idle")
	
func _process(delta: float) -> void:
	if detection_range.overlaps_body(player):
		print("gotcha!")
		if not player.current_form == Stats.Form.SHADOW:
			chase = true
	else:
		chase = false

func _physics_process(delta: float) -> void:
	if chase:
		print(navigation_agent.get_next_path_position())
		var direction = (navigation_agent.get_next_path_position() - self.position).normalized()
		velocity = direction * SPEED
		if attacking:
			pass
			#velocity.x = direction.x * SPEED * .75
		else:
			# Finding player
			sprite.play("Walk")
			if attack_range.overlaps_body(player):
				player.take_damage(10)
				attackPlayer()
				await sprite.animation_finished
				attacking = false

	else:
		sprite.play("Idle")
		velocity = Vector2.ZERO
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if direction.x < 0 and sprite.scale.x > 0 or direction.x > 0 and sprite.scale.x < 0:
		sprite.scale.x *= -1
	move_and_slide();

func attackPlayer():
	attacking = true
	sprite.play("Attack")
