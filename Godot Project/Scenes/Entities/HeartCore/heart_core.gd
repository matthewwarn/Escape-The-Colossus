extends AnimatedSprite2D

signal defeated;

@onready var immunity_time: Timer = $ImmunityTime
@onready var audio_manager = $"/root/GameManager/AudioManager"

var player_in_range: bool = false;
var health: int = 3;

func _on_player_detection_zone_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		print("in range")
		player_in_range = true 


func _on_player_detection_zone_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = false;


func _process(_delta: float) -> void:
	if Global.player_current_attack && player_in_range && immunity_time.is_stopped():
		immunity_time.start()
		$BloodSFX.play()
		health -= 1;
	if health <= 0:
		kill_self();


func kill_self():
	defeated.emit();
	audio_manager.play_roar();
	Global.core_one_defeated = true;
	print("Core defeated");
	self.queue_free();
