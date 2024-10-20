extends 'res://addons/gut/test.gd'

var game_manager = load("res://Scenes/game_manager.tscn").instantiate()
var Player = load("res://Scenes/Entities/Player/player.gd")
var Ribbug = load("res://Scenes/Entities/RibBug/rib_bug_test.gd")
var _player = null
var _ribbug = null
var health_before = null
var _sender = InputSender.new(Input)

func before_all():
	_ribbug = Ribbug.new()
	_player = Player.new()
	_ribbug.can_take_damage = true
	_ribbug.can_take_damage_zone = true
	_player.facing = -1
	_player.enemy_inattack_range = true
	_player.enemy_attack_cooldown = false

func after_all():
	pass

func test_attack_player():
	_sender.action_down("attack").hold_for(.1).wait(.3)
	await(_sender.idle)
	_player.attack()
	_ribbug.deal_with_damage()
	print(Global.player_current_attack)
	assert_true(Global.player_current_attack, "Player attack should be true")


func test_ribbug_death():
	Global.player_current_attack = true
	_ribbug.deal_with_damage()
	assert_eq(_ribbug.health, 0, "health should be 0")


func test_player_take_damage():
	_player.enemy_attack()
	assert_eq(_player.health, 2, "player health should be 2")


func test_player_death():
	_player.health = 1
	_player.enemy_attack()
	assert_eq(_player.health, 0, "should be 0")
