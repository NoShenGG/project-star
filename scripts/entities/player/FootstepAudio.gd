@tool
extends Node3D

@export var footstep_delay : float = 1
var delay_time : float = 0
var delayed : bool = false

@onready var audio : AudioStreamPlayer3D = self as Node3D
@export var skeleton : Skeleton3D

@export var feet_vfx : PooledOwner3D

var feet : PackedInt32Array

## primarily used to call play_footstep with animationplayers property track
@export var next_foot_playing : int = 0:
	set(x):
		play_footstep.call_deferred(x)
		return x
var foot_playing : int

signal footstep

func _ready() -> void:
	assert(skeleton != null,"skeleton is not assigned in FootstepAudio \n" + get_tree_string_pretty())

func _enter_tree() -> void:
	## bake it in editor so we dont waste a long bone and string search on startup. its o(n) and slow.
	if (skeleton and Engine.is_editor_hint()):
		feet.clear()
		FindFeetBoneIndex()
		
		skeleton.bone_list_changed.connect(FindFeetBoneIndex)

func _exit_tree() -> void:
	## bake it in editor so we dont waste a long bone and string search on startup. its o(n) and slow.
	## may or may not be called depending on if skeleton is already unloaded
	if (skeleton and Engine.is_editor_hint()):
		feet.clear()
		FindFeetBoneIndex()
		
		skeleton.bone_list_changed.disconnect(FindFeetBoneIndex)

func _process(delta):
	if (delayed):
		delay_time += delta
		if (delay_time >= footstep_delay):
			delayed = false
			delay_time = 0

## 0. left foot, 1. right foot. 2. back-left foot. 3. back-right foot. 4. repeat
func play_footstep(foot_index : float):
	## weirder version of rounding
	var rounded_foot_index : int = clamp(int(foot_index), 0, skeleton.get_bone_count()) if abs(foot_playing - foot_index) > 0.95 else foot_playing
	#animator can call a property value after getting destroyed i think. so get_tree()
	if (foot_playing == (rounded_foot_index) or delayed or !get_tree()): return
	foot_playing = rounded_foot_index
	audio.play()
	delayed = true
	#print("left foot  " + str(foot_playing) if foot_playing == 0 else "right foot  " + str(foot_playing))
	footstep.emit()
	
	spawn_foot_vfx(foot_playing)

func FindFeetBoneIndex(i : int = 0):
	for bone in skeleton.get_bone_children(i):
		
		var bone_name : String = skeleton.get_bone_name(bone)
		
		if (bone_name.to_lower().contains("foot") or bone_name.to_lower().contains("feet")):
			feet.append(bone)
		else:
			FindFeetBoneIndex(bone)

func spawn_foot_vfx(foot_index : int):
	if (feet.size() <= foot_index):
		return
	
	var down_direction : Vector3 = -skeleton.global_basis.y.normalized()
	var pose : Transform3D = skeleton.get_bone_global_pose(feet[foot_index])
	
	var foot_position = skeleton.global_position + (skeleton.global_basis * pose.origin)
	var query = PhysicsRayQueryParameters3D.create(foot_position + (-down_direction * 1.5), foot_position + (down_direction * 3.5), 1)
	query.hit_back_faces = false
	query.hit_from_inside = false
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if (result.is_empty()): return
	#print ("foot name   " + assembler.skeleton.get_bone_name(assembler.feet[foot_index]))
	
	var feet_vfx_instance = feet_vfx.get_spawned_instance()
	feet_vfx_instance.reparent(get_tree().current_scene)
	
	feet_vfx_instance.position = result.position # + (result.normal * 0)
	feet_vfx_instance.global_basis = Basis.looking_at((skeleton.global_basis.z), result.normal)
