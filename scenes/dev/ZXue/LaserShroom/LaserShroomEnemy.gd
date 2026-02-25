class_name LaserShroom extends Enemy

var player_ref : Player:
	get():
		return GameManager.curr_player

@export var hide_speed : float = 7.0
@export var aim_mesh: MeshInstance3D
@export var fire_mesh: MeshInstance3D
@export var warning_particles : GPUParticles3D
	
func _physics_process(_delta: float) -> void:
	super(_delta)
	
#for switching the meshes used for aiming & firing.
func switchMesh(status:int) -> void:
	'''
	status:
		1 == aim mesh only
		2 == fire mesh only
		0 == meshes default
	'''
	if (status == 1):
		aim_mesh.visible = true
		fire_mesh.visible = false
		warning_particles.emitting = true
	elif (status == 2):
		aim_mesh.visible = false
		fire_mesh.visible = true
		warning_particles.emitting = false
	else:
		aim_mesh.visible = false
		fire_mesh.visible = false
		warning_particles.emitting = false
