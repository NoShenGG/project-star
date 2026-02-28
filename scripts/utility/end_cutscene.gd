extends Node3D

@export var camera: Camera3D
@export var game_camera: Camera3D
@export var player_manager: PlayerManager

@export var pan_dur: float = 3.0
@export var boom_dur: float = 7.0

var playing : bool = false

signal scene_done
	
func start() -> void:
	for i in range(120):
		await get_tree().process_frame
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
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(camera, "fov", camera.fov+30, boom_dur)
	await tween.finished
	scene_done.emit()
