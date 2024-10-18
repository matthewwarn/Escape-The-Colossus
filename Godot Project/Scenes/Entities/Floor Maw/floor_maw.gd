extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_cooldown = $Attack_cooldown

var facing = 1
var health = 1               
var player_inattack_zone = false  #tracks weither player is in range to be attacked and to deal damage to enemy
var can_take_damage = true
var can_attack = true
var is_alive = true
var attack_ip = false

func _physics_process(delta):
	floormaw_enemy()
	attack()


func _on_proximity_detector_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		animated_sprite.play(&"Spawn")


func _on_proximity_detector_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		animated_sprite.play_backwards(&"Spawn");


#to play attack animation
func attack():
	var dir = facing
	if player_inattack_zone and can_attack:
		attack_ip = true
		if dir == 1:
			animated_sprite.flip_h = false
			animated_sprite.play("Attack")
			attack_cooldown.start()
			attack_ip = false
			can_attack = false
		if dir == -1:
			animated_sprite.flip_h = true
			animated_sprite.play("Attack")
			attack_cooldown.start()
			attack_ip = false
			can_attack = false


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == &"Spawn":
		# check whether the spawn animation was played backwards
		if animated_sprite.frame == 0:
			animated_sprite.play(&"Unspawned");
		else:
			animated_sprite.play(&"Active");


func _on_deal_damage_hitbox_body_entered(body):
	if body.has_method("player"):
		player_inattack_zone = true


func _on_deal_damage_hitbox_body_exited(body):
	player_inattack_zone = false


func _on_attack_cooldown_timeout():
	can_attack = true


#for player to identify its an enemy and should take damge
func floormaw_enemy():
	pass
