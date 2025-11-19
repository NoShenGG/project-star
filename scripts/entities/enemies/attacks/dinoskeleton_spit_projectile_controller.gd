class_name SpitProjectileController extends Node3D

@export var projectile_node: Node3D
@export var aoe_scene: PackedScene

@onready var timer: Timer = $Timer

var _start_position: Vector3
var _end_position: Vector3

func setup(start_position: Vector3, end_position: Vector3) -> void:
	_start_position = start_position
	_end_position = end_position
	
	global_position = _start_position
	if projectile_node:
		projectile_node.position = Vector3.ZERO
	projectile_node.visible = true
	
	timer.start()
	
func _process(delta: float) -> void:
	var lerp_val := 1.0 - (timer.time_left / timer.wait_time)
	lerp_val = clamp(lerp_val, 0, 1)
	
	if lerp_val >= 1:
		_coallesce_projectile()
	else:
		global_position = _get_projectile_position(lerp_val)
	
func _get_projectile_position(lerp_val: float) -> Vector3:
	var x = lerp(_start_position.x, _end_position.x, lerp_val)
	var y = lerp(_start_position.y, _end_position.y, lerp_val * lerp_val)
	var z = lerp(_start_position.z, _end_position.z, lerp_val)
	return Vector3(x, y, z)

func _coallesce_projectile() -> void:
	set_process(false)
	
	projectile_node.visible = false
	var aoe = aoe_scene.instantiate()
	get_tree().current_scene.add_child(aoe)
	aoe.global_position = global_position
	print(aoe.global_position)
