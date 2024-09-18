extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var coyote_timer = $CoyoteTimer
@onready var attack_cooldown = $attack_cooldown
@onready var deal_attack_timer = $deal_attack_timer
@onready var animation_player = $Camera2D/AnimationPlayer

var full_heart_texture = preload("res://Scenes/Entities/Player/Health/Heart.png")
var damaged_heart_texture = preload("res://Scenes/Entities/Player/Health/DamagedHeart.png")
var empty_heart_texture = preload("res://Scenes/Entities/Player/Health/EmptyHeart.png")

signal player_died;

const SPEED: float            = 160.0
const JUMP_VELOCITY: float    = -300.0
const FALL_GRAVITY: int       = 1100
const DASH_VELOCITY: float    = 500.0
const DASH_DURATION: float    = 0.15
const DASH_COOLDOWN: float    = 0.15
const JUMP_BUFFER_TIME: float = 0.07

var facing: int = 1

var jump: bool = false
var double_jump_available: bool = false
var double_jump_toggle: bool = false
var jump_buffer: bool = false

var is_dashing: bool = false
var is_dash_cooling_down: bool = false
var dash_toggle: bool = true;
var dash_timer: float          = 0.0
var dash_cooldown_timer: float = 0.0

var enemy_attack_cooldown: bool = true
var enemy_inattack_range: bool  = false
var health: int                 = 3
var attack_ip: bool             = false
var is_alive: bool              = true

# The hearts get initialised in _ready()
var heart1
var heart2
var heart3

# Get the default gravity from project settings. Which is 980.
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	heart1 = get_node("CanvasLayer/Heart1")
	heart2 = get_node("CanvasLayer/Heart2")
	heart3 = get_node("CanvasLayer/Heart3")

# If player is jumping, normal gravity. If player is falling, fall gravity.
func return_gravity(v: Vector2):
	if v.y < 0:
		return GRAVITY
	return FALL_GRAVITY

# Can be used when the player unlocks a new powerup. Or for debugging
func toggle_powerups(powerup: String):
	if powerup == "dash":
		dash_toggle = not dash_toggle
		
		if dash_toggle == true:
			print("DASH ENABLED")
		else:
			print("DASH DISABLED")
			
	elif powerup == "double jump":
		double_jump_toggle = not double_jump_toggle
		
		if double_jump_toggle == true:
			print("DOUBLE JUMP ENABLED")
		else:
			print("DOUBLE JUMP DISABLED")

func _physics_process(delta):
	if health < 1:
		player_died.emit();
	else:
		enemy_attack();
		attack();

	# Storing if the player just left the floor, for Coyote time.
	var was_on_floor: bool = is_on_floor()
	
	# DEBUGGING! TOGGLE POWERUPS!
	if Input.is_action_just_pressed("toggle_dash"): # F1 key
		toggle_powerups("dash")
	elif Input.is_action_just_pressed("toggle_double_jump"): # F2 key
		toggle_powerups("double jump")
	
	if not is_on_floor():
		# Apply gravity when player isn't dashing.
		if not is_dashing:
			velocity.y += return_gravity(velocity) * delta
	else: # If on floor
		if jump_buffer:
			velocity.y = JUMP_VELOCITY
			jump_buffer = false
	
	# Allows player to do smaller jumps.
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY / 4
	
	# Reset double jump.
	if is_on_floor():
		double_jump_available = true

	# Handle jump and double jump.
	if Input.is_action_just_pressed("jump"): 
		# If on floor, do normal jump
		if is_on_floor() || !coyote_timer.is_stopped():
			velocity.y = JUMP_VELOCITY
			
		# If not on floor, use double jump
		elif double_jump_toggle and double_jump_available:
			velocity.y = JUMP_VELOCITY
			double_jump_available = false
			
		# If neither jump available, start jump buffer timer
		else:
			jump_buffer = true
			get_tree().create_timer(JUMP_BUFFER_TIME).timeout.connect(on_jump_buffer_timeout)
	
	# Get the input direction and handle the movement/deceleration.
	var move_left: bool  = Input.is_action_pressed("move_left")
	var move_right: bool = Input.is_action_pressed("move_right")
	
	#Handle dash.
	if Input.is_action_just_pressed("dash") && dash_toggle && not is_dashing && not is_dash_cooling_down:
		is_dashing = true
		dash_timer = DASH_DURATION
		
	if is_dashing:
		velocity.x = DASH_VELOCITY * facing
		velocity.y = 0 # Prevents falling or rising during dash
		dash_timer -= delta
		
		# Reset dash and start dash cooldown
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
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0 && is_on_floor():
			is_dash_cooling_down = false;
	
	move_and_slide()
	
	# Start Coyote Timer if just walked off floor.
	if was_on_floor and not is_on_floor():
		coyote_timer.start()
		
	# Play Animations
	if is_on_floor():
			if velocity.x == 0:
				animated_sprite.animation = "Idle"
			else:
				animated_sprite.animation = "Movement"
	else:
		animated_sprite.animation = "Jump"

func on_jump_buffer_timeout()->void:
	jump_buffer = false

func player():
	pass

func enemy_attack():	
	if enemy_inattack_range and enemy_attack_cooldown == false:
		update_hearts(health)
		health = health - 1
		enemy_attack_cooldown = true
		attack_cooldown.start()
		

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = false

func attack():
	var dir: int = facing
	
	if Input.is_action_just_pressed("attack") and enemy_attack_cooldown == true:
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

# Takes the health the player had right BEFORE getting hit
func update_hearts(health):
	match health:
		1:
			heart1.texture = empty_heart_texture
		2:
			heart2.texture = empty_heart_texture
		3:
			heart3.texture = empty_heart_texture

func _on_deal_attack_timer_timeout():
	deal_attack_timer.stop()
	globall.player_current_attack = false 
	attack_ip = false 

func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_inattack_range = true 
		enemy_attack_cooldown = false

func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_inattack_range = false
		enemy_attack_cooldown = true
		
func _on_area_2d_body_entered(body):
	if body.name == "Player":
		print("Entered")
		double_jump_toggle = true
		animation_player.play("move_left")
