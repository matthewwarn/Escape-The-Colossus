extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

@onready var deal_attack_timer = $deal_attack_timer

const SPEED = 160.0
const JUMP_VELOCITY = -300.0
const FALL_GRAVITY = 1100
const DASH_VELOCITY = 500.0
const DASH_DURATION = 0.15
const DASH_COOLDOWN = 0.15

var facing = 1
var jump: bool = false
var double_jump: bool = false
var is_dashing: bool = false
var is_dash_cooling_down: bool = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0

var attack_cooldown = true
var enemy_inattack_range = false
var health = 3
var attack_ip = false

# Get the default gravity from project settings. Which is 980.
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

# If player is jumping, normal gravity. If player is falling, fall gravity.
func return_gravity(velocity: Vector2):
	if velocity.y < 0:
		return GRAVITY
	return FALL_GRAVITY


func _physics_process(delta):
	enemy_attack()
	attack()
	
	# Add the gravity when player isn't dashing.
	if not is_on_floor() and not is_dashing:
		velocity.y += return_gravity(velocity) * delta
	
	# Allows player to do smaller jumps.
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY / 4
	
	# Reset double jump.
	if is_on_floor():
		jump = false
		double_jump = false

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump = true
		
	# Handle double jump.
	if Input.is_action_just_pressed("jump") and not is_on_floor() and double_jump == false:
		velocity.y = JUMP_VELOCITY
		double_jump = true;
		
	# Get the input direction and handle the movement/deceleration.
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	
	#Handle dash.
	if Input.is_action_just_pressed("dash") && not is_dashing && not is_dash_cooling_down:
		is_dashing = true
		dash_timer = DASH_DURATION
		
	if is_dashing:
		velocity.x = DASH_VELOCITY * facing
		velocity.y = 0 # Prevents falling or rising during dash
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			is_dash_cooling_down = true
			dash_cooldown_timer = DASH_COOLDOWN
	else:
		if move_left:
			animated_sprite.flip_h = false
			velocity.x = -SPEED
			facing = -1
		elif move_right:
			animated_sprite.flip_h = true
			velocity.x = SPEED
			facing = 1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Dash Cooldown
	if is_dash_cooling_down:
		print("COOLDOWN: " + str(dash_cooldown_timer))
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0 && is_on_floor():
			is_dash_cooling_down = false;
	move_and_slide()
	
func player():
	pass
	
func _on_palyer_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_inattack_range = true 
		
func _on_palyer_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_inattack_range = false
		
func enemy_attack():	
	if enemy_inattack_range and attack_cooldown == true:
		health = health - 1
		attack_cooldown = false 
		attack_cooldown.start()
		print(health)

func _on_attack_cooldown_timeout():
	attack_cooldown = true
	
func attack():
	var dir = facing
	
	if Input.is_action_just_pressed("attack"):
		globall.player_current_attack = true
		attack_ip = true
		if dir == 1:
			animated_sprite.flip_h = true
			animated_sprite.play("Attack")
			deal_attack_timer.start()
		if dir == -1:
			animated_sprite.flip_h = false
			animated_sprite.play("Attack")
			deal_attack_timer.start()
	else:
		attack_ip = false

func _on_deal_attack_timer_timeout():
	deal_attack_timer.stop()
	globall.player_current_attack = false 
	attack_ip = false 
	
