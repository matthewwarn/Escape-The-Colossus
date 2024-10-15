extends CharacterBody2D

const CHASE_SPEED = 3000               #this speed is for when chasing player
const SPEED = 50                       #this speed is used when not chasing player
const JUMP_VELOCITY: float = -400.0
const FALL_GRAVITY = 1100

var player = null
var health = 1
var direction = -1                       #this will be used for when enemy chases player
var facing = - 1                         #this is used when ribbug has engaged player but is no longer chasing player
var is_jumping: bool = false
var player_chase: bool = false           #tracks weither if enemy should chase player or not
var player_in_attack_zone: bool = false  #tracks weither player is in range to be attacked 
var can_take_damage_zone: bool = false   #tracks weither the player in in range to deal damage to ribbug
var can_take_damage: bool = true
var can_attack: bool = true
var is_alive: bool = true
var attack_ip: bool = false              #tracks if enemy is attacking
var has_engaged: bool = false            #tracks if player has engaged enemy 
var can_chase: bool = true               #tracks if enemy can chase player 

@onready var attack_cooldown = $attack_cooldown
@onready var take_damage_cooldown = $take_damage_cooldown
@onready var chase_cooldown = $chase_cooldown
@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_jump = $RayCast_jump
@onready var jump_time = $Jump_time
@onready var ray_cast_wall = $RayCastWall
@onready var ray_cast_floor = $RayCastFloor

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
		can_attack = false
	
	#to enable gravity
	if not is_on_floor():
		if is_jumping == false:
			velocity.y += gravity * delta 
		else:
			velocity.y += FALL_GRAVITY * delta
	
	#if RibBug there is floor infornt of the ribbug
	
	if player_chase == true:
		chase_player(delta)
	elif has_engaged == true and player_chase == false and is_jumping == false: #if RibBug has engaged the player then it will move around on platform
		if (facing) < 0:
			animated_sprite.flip_h = false
			ray_cast_floor.position.x = -13
			ray_cast_wall.scale.x = 1
			ray_cast_jump.position.x = -16
		else:
			animated_sprite.flip_h = true
			ray_cast_floor.position.x = 13
			ray_cast_wall.scale.x = -1
			ray_cast_jump.position.x = 16
			
		if ray_cast_wall.is_colliding():
			if (facing) < 0:
				animated_sprite.flip_h = true
				facing = 1
				ray_cast_floor.position.x = 13
				ray_cast_wall.scale.x = -1
				ray_cast_jump.position.x = 16
			else:
				animated_sprite.flip_h = false
				facing = -1
				ray_cast_floor.position.x = -13
				ray_cast_wall.scale.x = 1
				ray_cast_jump.position.x = -16
			can_chase = false
			player_chase = false
			position.x += facing * SPEED * delta
			chase_cooldown.start()
		elif ray_cast_floor.is_colliding() == false:
			if (facing) < 0:
				animated_sprite.flip_h = true
				facing = 1
				ray_cast_floor.position.x = 13
				ray_cast_wall.scale.x = -1
				ray_cast_jump.position.x = 16
			else:
				animated_sprite.flip_h = false
				facing = -1
				ray_cast_floor.position.x = -13
				ray_cast_wall.scale.x = 1
				ray_cast_jump.position.x = -16
			can_chase = false
			player_chase = false
			position.x += facing * SPEED * delta
			chase_cooldown.start()
		position.x += facing * SPEED * delta
	move_and_slide()
	# for when the player is in the RibBug's detection area 
	

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


#handling chasing the player
func chase_player(delta):
	direction = (player.position.x - position.x)
	
	if (direction) < 0:
		animated_sprite.flip_h = false
		ray_cast_floor.position.x = -13
		ray_cast_wall.scale.x = 1
		ray_cast_jump.position.x = -16
	else:
		animated_sprite.flip_h = true
		ray_cast_floor.position.x = 13
		ray_cast_wall.scale.x = -1
		ray_cast_jump.position.x = 16
	
	
	#if RibBug is on the floor
	if ray_cast_floor.is_colliding():
		if ray_cast_wall.is_colliding():
			jump(delta)
			position.x += direction / (CHASE_SPEED * delta ) #this is for chasing the player
	elif ray_cast_floor.is_colliding() == false: #for when there is no floor
		jump(delta)
		position.x += direction / (CHASE_SPEED * delta ) #this is for chasing the player
		
	position.x += direction / (CHASE_SPEED * delta ) #this is for chasing the player
	move_and_slide()


#this function is how the ribbug attacks 
func attack():
	if player_in_attack_zone and can_attack:
		attack_ip = true
		if facing == 1:
			animated_sprite.flip_h = true
			animated_sprite.play("Attack")
			attack_cooldown.start()
			attack_ip = false
			can_attack = false
		if facing == -1:
			animated_sprite.flip_h = false
			animated_sprite.play("Attack")
			attack_cooldown.start()
			attack_ip = false
			can_attack = false


#this function is how to deal with damage taken
func deal_with_damage():
	if can_take_damage_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			$HitSFX.play()
			health = health - 1
			take_damage_cooldown.start()
			can_take_damage = false


func jump(delta):
	# If on floor, do normal jump
	if is_on_floor(): 
		velocity.y += JUMP_VELOCITY
		velocity.x += direction / (CHASE_SPEED * delta ) #this is for chasing the player
		is_jumping = true


#this is used by player to check if it is an enemy 
func enemy():
	pass


# for when the player enters the engament area thus ribbug starts to chase
func _on_detection_body_entered(body):
	if body.has_method("player"):
		player = body
		if can_chase == true:
			player_chase = true


# for when the player leaves the engament area
func _on_detection_body_exited(_body):
	player_chase = false
	has_engaged = true


#for when player enters the area when the ribbug can attack
func _on_deal_damage_hit_box_body_entered(body):
	if body.has_method("player"):
		player_in_attack_zone = true


#for when player enters the area when the ribbug can attack
func _on_deal_damage_hit_box_body_exited(body):
	if body.has_method("player"):
		player_in_attack_zone = false


#for when player enters the area when the ribbug can take damage
func _on_recieve_damage_hit_box_body_entered(body):
	if body.has_method("player"):
		can_take_damage_zone = true


#for when player leaves the area when the ribbug can take damage
func _on_recieve_damage_hit_box_body_exited(body):
	if body.has_method("player"):
		can_take_damage_zone = false

#this is what happens when the timer that is for being able to recive damage times out
func _on_take_damage_cooldown_timeout():
	can_take_damage = true


#this is what happens when the timer that is for the attack cooldown times out
func _on_attack_cooldown_timeout():
	can_attack = true


#this timer is so that the ribbug doesn't instantly try and chase the player after it turns around 
func _on_chase_cooldown_timeout():
	can_chase = true
	

func _on_jump_time_timeout():
	is_jumping = false


#for when death animation is finnished to remove the instacnce of that ribbug
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == &"Death ":
		self.queue_free()
