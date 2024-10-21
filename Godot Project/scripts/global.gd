extends Node

var player_current_attack = false

var checkpoint_reached: bool = false
var checkpoint_position: Vector2 = Vector2(0, 0)

var speedrun_time: float = 0
var formatted_time: String

var core_one_defeated: bool = false;
var core_two_defeated: bool = false;

var pause_available: bool = true;
