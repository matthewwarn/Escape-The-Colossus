extends CharacterBody2D

const SPEED = 50
var player_chase = false
var player = null
var health = 100
var direction = -1

@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	
		
	if player_chase:
			
		if (direction) < 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
			
		if ray_cast_left.is_colliding():
			direction = 1
			animated_sprite.flip_h = true
		if ray_cast_right.is_colliding():
			direction = -1
			animated_sprite.flip_h = false
			
		if not is_on_floor():
			velocity.y += gravity * delta
		
		position.x += direction * SPEED * delta 
	else:
		animated_sprite.play("Idle")
	
	move_and_slide()
func _on_detection_body_entered(body):
	player = body
	player_chase = true
	#direction = (player.position.x - position.x)

func _on_detection_body_exited(body):
	player = null
	player_chase = false
	
	
