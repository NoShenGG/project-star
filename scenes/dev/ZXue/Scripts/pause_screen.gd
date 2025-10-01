#This is made by Zifeng Xue.
#This is a preliminary Pause Screen, without much of a thought. I understand there is a better way of achieving this,
#but GDScript was not very kind with me tonight, so I eventually decided to resort to this solution.
#I added a new input mapping that takes ESC as the cue for calling up the pause screen.


extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_pressed("pause_game"):#If esc is pressed
		get_tree().paused = true;
		show();#This node's process mode is set to "Aways", allowing it to operate as usual.
		#This given, if we want to make systems available during pause,
		#set them to "When paused".
		#I WILL FIND OUT A BETTER WAY TO DO THIS I PROMISE


func _on_continue_button_pressed() -> void:#exit paused mode
	get_tree().paused = false;
	hide();


func _on_exit_button_pressed() -> void:#exit game, for now
	get_tree().quit();
