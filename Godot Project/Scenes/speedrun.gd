extends CanvasLayer

var time = Global.speedrun_time

func _physics_process(delta):
	time = float(Global.speedrun_time) + delta
	
	update_ui();

func update_ui():
	var minutes = int(time) / 60
	var seconds = time - minutes * 60
	
	var formatted_minutes = str(minutes).pad_zeros(2)
	var formatted_seconds = str(seconds).pad_zeros(2)
	var decimal_index = formatted_seconds.find(".")
	
	if decimal_index > 0:
		formatted_seconds = formatted_seconds.left(decimal_index + 3)
	else:
		formatted_seconds += ".00"
	
	if formatted_seconds.find(".") == len(formatted_seconds) - 2:
		formatted_seconds += "0"
	
	
	Global.formatted_time = formatted_minutes + ":" + formatted_seconds
	
	Global.speedrun_time = time
	
	$Label.text = Global.formatted_time
