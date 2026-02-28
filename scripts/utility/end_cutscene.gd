extends Node3D

@export var camera: Camera3D
@export var game_camera: Camera3D
@export var player_manager: PlayerManager
@export var sound: FmodEventEmitter3D
@export var vfx: AnimationPlayer
@export var white: Control

@export var pan_dur: float = 3.0
@export var boom_dur: float = 7.0

var playing : bool = false

signal scene_done

func _ready() -> void:
	vfx.play("RESET")
	
func start() -> void:
	player_manager.players[0].global_position = Vector3(70.23958, 8.44173, -148.463)
	player_manager.players[0].rotation_degrees = Vector3(0.0, 0.0, 0.0)
	player_manager.players[0].show()
	player_manager.players[1].hide()
	player_manager.players[2].hide()
	player_manager.process_mode = Node.PROCESS_MODE_DISABLED
	var target_trans = camera.global_transform
	camera.global_transform = game_camera.global_transform
	camera.current = true
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(camera, "global_transform", target_trans, pan_dur)
	await tween.finished
	nova_boom()

func nova_boom() -> void:
	
	vfx.play("explosion")
	var len = vfx.current_animation_length
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(camera, "fov", camera.fov+30, len)
	tween.parallel().tween_property(white, "modulate", Color("ffffffff"), 1) \
			.set_delay(len - 2)
	await get_tree().create_timer(2).timeout
	sound.play_one_shot()
	await tween.finished
	scene_done.emit()
