extends CharacterBody2D

const SPEED = 4000
const JUMP_VELOCITY = -500.0
const JUMP_BUFFER_TIME = 0.07

var player_chase = false
var player = null
var health = 1
var direction = -1
var player_inattack_zone = false 
var can_take_damage = true
var can_attack = true
var is_alive = true
var jump_buffer: bool = false
var attack_ip = false

@onready var attack_cooldown = $attack_cooldown
@onready var take_damage_cooldown = $take_damage_cooldown
@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_floor = $RayCastFloor
@onready var ray_cast_floor_2 = $RayCastFloor2

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	
	play_animation()
	deal_with_damage()
	attack()
	enemy()
	

	if health <= 0:
		is_alive = false
		player_chase = false

	if player_chase:
		
		if (direction) < 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true

		if ray_cast_floor.is_colliding() and ray_cast_floor_2.is_colliding():
			
			if ray_cast_left.is_colliding():
				if velocity.y < 0 and is_on_floor():
					velocity.y = JUMP_VELOCITY / 4
					jump_buffer = true
					#if ray_cast_left.is_colliding():
						#direction = 1
						#animated_sprite.flip_h = true

			if ray_cast_right.is_colliding():
				if velocity.y < 0 and is_on_floor():
					velocity.y = JUMP_VELOCITY / 4
					jump_buffer = true
					#if ray_cast_right.is_colliding():
						#direction = -1
						#animated_sprite.flip_h = false

			if not is_on_floor():
				velocity.y += gravity * delta
			else:
				if jump_buffer:
					velocity.y = JUMP_VELOCITY
					jump_buffer = false

			position.x += direction / (SPEED * delta )

		elif ray_cast_floor.is_colliding() == false or ray_cast_floor_2.is_colliding() == false:
			if (direction) < 0:
				direction = 1
				animated_sprite.flip_h = true
			else:
				direction = -1
				animated_sprite.flip_h = false
			
			position.x += direction * SPEED * delta 
	
	move_and_slide()

func play_animation():
	if player_chase == false and is_alive == true :
		animated_sprite.play("Idle")
	elif player_chase == true and is_alive == true and attack_ip == false:
		animated_sprite.play("Walking")
	elif player_chase == true and is_alive == true and attack_ip == true:
		animated_sprite.play("Attack")
	elif is_alive == false:
		animated_sprite.play("Death ")
		#self.queue_free()

func _on_detection_body_entered(body):
	if body.has_method("player"):
		player = body
		player_chase = true
		direction = (player.position.x - position.x)

func _on_detection_body_exited(body):
	player = body
	player = null
	player_chase = false

func _on_hit_box_body_entered(body):
	if body.has_method("player"):
		player_inattack_zone = true 

func _on_hit_box_body_exited(body):
	if body.has_method("player"):
		player_inattack_zone = false

func attack():
	var dir = direction
	if player_inattack_zone and can_attack:
		attack_ip = true
		if dir == 1:
			animated_sprite.flip_h = true
			animated_sprite.play("Attack")
			attack_cooldown.start()
			attack_ip = false
		if dir == -1:
			animated_sprite.flip_h = false
			animated_sprite.play("Attack")
			attack_cooldown.start()
			attack_ip = false

func deal_with_damage():
	if player_inattack_zone and globall.player_current_attack == true:
		if can_take_damage == true:
			health = health - 1
			take_damage_cooldown.start()
			can_take_damage = false
			print("RibBug health: " + str(health))
		
func _on_take_damage_cooldown_timeout():
	can_take_damage = true


func _on_attack_cooldown_timeout():
	can_attack = true

func enemy():
	pass
