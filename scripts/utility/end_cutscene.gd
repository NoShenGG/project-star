extends Node3D

@export var camera: Camera3D
@export var game_camera: Camera3D
@export var player_manager: PlayerManager
@export_category("Fake Nove")
@export var fake_nova: Node3D
@export var move_state: AnimationState
@export var idle: AnimationState

@export var fade_time: float = 0.2
@export var walk_dur : float = 3

var playing : bool = false

func _ready() -> void:
	#while true:
	#	if Input.is_key_pressed(KEY_0): break;
	#start()
	pass
	
	
func start() -> void:
	var game_env = get_viewport().get_camera_3d().environment
	var new_env = camera.environment
	var target_bright = new_env.adjustment_brightness
	new_env.adjustment_brightness = 0
	
	# Fade Black
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(game_env, "adjustment_brightness", 0, fade_time)
	await tween.finished
	# Hide Regular Stuff
	camera.current = true
	player_manager.hide()
	player_manager.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(0.1).timeout
	
	# Fade In and Walk Nova
	move_state.enter()
	tween = get_tree().create_tween()
	tween.tween_property(new_env, "adjustment_brightness", target_bright, fade_time)
	tween.parallel().tween_property(fake_nova, "global_transform", 
			fake_nova.global_position + Vector3(0.0, 0.0, -6.0), walk_dur)
	await tween.finished


func nova_boom() -> void:
	pass
