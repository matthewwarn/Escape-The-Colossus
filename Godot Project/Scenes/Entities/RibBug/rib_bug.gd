extends CharacterBody2D

const CHASE_SPEED = 4000          #this speed is for when chasing player
const SPEED = 50                  #this speed is used when not chasing player

var player_chase = false          #tracks weither if enemy should chase player or not
var player = null
var health = 1
var direction = -1                #this will be used for when enemy chases player
var player_inattack_zone = false  #tracks weither player is in range to be attacked and to deal damage to enemy
var can_take_damage = true
var can_attack = true
var is_alive = true
var attack_ip = false             #tracks if enemy is attacking
var facing = - 1                  #this is used when ribbug has engaged player but is no longer chasing player
var has_engaged: bool = false     #tracks if player has engaged enemy 
var can_chase: bool = true        #tracks if enemy can chase player 

@onready var attack_cooldown = $attack_cooldown
@onready var take_damage_cooldown = $take_damage_cooldown
@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_floor_left = $RayCastFloorLeft
@onready var ray_cast_floor_right = $RayCastFloorRight

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	
	play_animation()
	deal_with_damage()
	attack()
	enemy()
	
#when RibBug dies set is_alive and player_chase to false 
	if health <= 0:
		is_alive = false
		player_chase = false
	
	#to enable gravity
	if not is_on_floor():
		velocity.y += gravity * delta 
	
	# for when the player is in the RibBug's detection area 
	if player_chase:
		
		if (direction) < 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
		
		#if RibBug is on the floor
		if ray_cast_floor_left.is_colliding() and ray_cast_floor_right.is_colliding():
			
			#can_chase = true 
			
			if ray_cast_right.is_colliding():
				animated_sprite.flip_h = false
				facing = -1
				position.x += facing * SPEED * delta
			elif ray_cast_left.is_colliding():
				animated_sprite.flip_h = true
				facing = 1
				position.x += facing * SPEED * delta 
			else:
				position.x += direction / (CHASE_SPEED * delta ) #this is for chasing the player
		
		elif ray_cast_floor_left.is_colliding() == false or ray_cast_floor_right.is_colliding() == false: #for when there is no floor
			
			can_chase = false
			
			if ray_cast_floor_left.is_colliding() == false and ray_cast_floor_right.is_colliding():
				animated_sprite.flip_h = true
				facing = 1
				position.x += facing * SPEED * delta
			elif ray_cast_floor_right.is_colliding() == false and ray_cast_floor_left.is_colliding():
				animated_sprite.flip_h = false
				facing = -1
				position.x += facing * SPEED * delta
	
	elif has_engaged == true and player_chase == false: #if RibBug has engaged the player then it will move around on platform
		
		if (facing) < 0:
			animated_sprite.flip_h = false
			
		else:
			animated_sprite.flip_h = true
			
	 	
		if ray_cast_floor_left.is_colliding() and ray_cast_floor_right.is_colliding():
			
			#can_chase = true
			
			if ray_cast_right.is_colliding():
				animated_sprite.flip_h = false
				facing = -1
				position.x += facing * SPEED * delta
			elif ray_cast_left.is_colliding():
				animated_sprite.flip_h = true
				facing = 1
				position.x += facing * SPEED * delta 
			
			position.x += facing * SPEED * delta
		
		elif ray_cast_floor_left.is_colliding() == false or ray_cast_floor_right.is_colliding() == false:
			
			can_chase = false
			
			if ray_cast_floor_left.is_colliding() == false and ray_cast_floor_right.is_colliding():
				animated_sprite.flip_h = true
				facing = 1
				position.x += facing * SPEED * delta
			elif ray_cast_floor_right.is_colliding() == false and ray_cast_floor_left.is_colliding():
				animated_sprite.flip_h = false
				facing = -1
				position.x += facing * SPEED * delta
			
		position.x += facing * SPEED * delta
	
	move_and_slide()

#playing the different animations
func play_animation():
	if player_chase == false and is_alive == true :
		animated_sprite.play("Idle")
	elif player_chase == true and is_alive == true and attack_ip == false:
		animated_sprite.play("Walking")
	elif player_chase == true and is_alive == true and attack_ip == true:
		animated_sprite.play("Attack")
	elif is_alive == false:
		animated_sprite.play("Death ")
		

# for when the player enters the engament area thus ribbug starts to chase
func _on_detection_body_entered(body):
	if body.has_method("player"):
		player = body
		if can_chase == true:
			player_chase = true
			direction = (player.position.x - position.x)

# for when the player leaves the engament area
func _on_detection_body_exited(body):
	player = body
	player = null
	player_chase = false
	has_engaged = true

#for when player enters the area when the ribbug can take damage and attack
func _on_hit_box_body_entered(body):
	if body.has_method("player"):
		player_inattack_zone = true 

#for when player leaves the area when the ribbug can take damage and attack
func _on_hit_box_body_exited(body):
	if body.has_method("player"):
		player_inattack_zone = false

#this function is how the ribbug attacks 
func attack():
	var dir = facing
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

#this function is how to deal with damage taken
func deal_with_damage():
	if player_inattack_zone and globall.player_current_attack == true:
		if can_take_damage == true:
			health = health - 1
			take_damage_cooldown.start()
			can_take_damage = false
			print("RibBug health: " + str(health))
		

#this is what happens when the timer that is for being able to recive damage times out
func _on_take_damage_cooldown_timeout():
	can_take_damage = true

#this is what happens when the timer that is for the attack cooldown times out
func _on_attack_cooldown_timeout():
	can_attack = true

#this is used by player to check if it is an enemy 
func enemy():
	pass

#for when death animation is finnished to remove the instacnce of that ribbug
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == &"Death ":
		self.queue_free()
