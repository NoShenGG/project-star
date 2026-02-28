class_name LaserShroom extends Enemy

var player_ref : Player
var original_basis : Basis

@export var default_speed : float = 5.0

func _ready() -> void:
	player_ref = GameManager.curr_player
	speed = default_speed
	$Hitbox.set_disabled(false)
	killed.connect(func(): state_machine.state.trigger_finished.emit("dead"))
	super()
	
func _physics_process(_delta: float) -> void:
	super(_delta)
	
#for switching the meshes used for aiming & firing.
func switchMesh(status:int) -> void:
	'''
	status:
		0 == meshes off
		1 == aim mesh only
		2 == fire mesh only
		# == meshes off (default)
	'''
	if (status == 0):
		$Hitbox/AimMesh.visible = false
		$Hitbox/FireMesh.visible = false
	elif (status == 1):
		$Hitbox/AimMesh.visible = true
		$Hitbox/FireMesh.visible = false
	elif (status == 2):
		$Hitbox/AimMesh.visible = false
		$Hitbox/FireMesh.visible = true
	else:
		$Hitbox/AimMesh.visible = false
		$Hitbox/FireMesh.visible = false
