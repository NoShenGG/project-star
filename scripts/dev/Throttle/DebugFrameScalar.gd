extends Node

@export var frame_change_speed : float = 2
@export var time_change_speed : float = 2

@export var max_frame_rate_label : Label
@export var current_frame_rate_label : Label
@export var time_scale_label : Label
@export var physics_frame_rate_label : Label

var frame_change_index : int = 3
var time_scale_index : int = 3
var physics_change_index : int = 1


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("time_scale_increase")):
		time_scale_index += 1
	elif (Input.is_action_just_pressed("time_scale_decrease")):
		time_scale_index -= 1
	
	if (Input.is_action_just_pressed("frame_increase")):
		frame_change_index += 1
	elif (Input.is_action_just_pressed("frame_decrease")):
		frame_change_index -= 1
	if (Input.is_action_just_pressed("physics_increase")):
		physics_change_index += 1
	elif (Input.is_action_just_pressed("physics_decrease")):
		physics_change_index -= 1
	
	frame_change_index = clampi(frame_change_index, 0, 3)
	time_scale_index = clampi(time_scale_index, 0, 5)
	physics_change_index = clampi(physics_change_index, 0, 2)
	
	match (time_scale_index):
		(0):
			Engine.time_scale = 0.25
		(1):
			Engine.time_scale = 0.5
		(2):
			Engine.time_scale = 0.75
		(3):
			Engine.time_scale = 1
		(4):
			Engine.time_scale = 1.5
		(5):
			Engine.time_scale = 2
	
	match (frame_change_index):
		(0):
			Engine.max_fps = 15
		(1):
			Engine.max_fps = 40
		(2):
			Engine.max_fps = 60
		(3):
			Engine.max_fps = 150
	
	match (physics_change_index):
		(0):
			Engine.physics_ticks_per_second = 10
		(1):
			Engine.physics_ticks_per_second = 60
		(2):
			Engine.physics_ticks_per_second = 120
	
	max_frame_rate_label.text = "Max Frame Rate \n" + str(Engine.max_fps)
	current_frame_rate_label.text = "Current Frame Rate \n" + str(Engine.get_frames_per_second())
	time_scale_label.text = "Time Scale \n" + str(Engine.time_scale)
	physics_frame_rate_label.text = "Physics Frame Rate \n" + str(Engine.physics_ticks_per_second)
	
	
	return
	## INFO heres a different style with direct speeds, rn i like index more though
	#Engine.time_scale += time_change_speed if Input.is_action_pressed("time_scale_increase") else 0
	#Engine.time_scale -= time_change_speed if Input.is_action_pressed("time_scale_decrease") else 0
	#Engine.time_scale = (roundf(Engine.time_scale * 100) / 100)
	#Engine.time_scale = max(Engine.time_scale, 0)
	#
	#Engine.max_fps += frame_change_speed if Input.is_action_pressed("frame_increase") else 0
	#Engine.max_fps -= frame_change_speed if Input.is_action_pressed("frame_decrease") else 0
	##Engine.max_fps = max(Engine.max_fps, 0)
	#
	#
	#max_frame_rate_label.text = "Max Frame Rate \n" + str(Engine.max_fps)
	#current_frame_rate_label.text = "Current Frame Rate \n" + str(Engine.get_frames_per_second())
	#time_scale_label.text = "Time Scale \n" + str(Engine.time_scale)
