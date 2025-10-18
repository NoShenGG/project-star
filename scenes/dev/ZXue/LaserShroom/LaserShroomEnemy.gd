class_name LaserShroom extends Enemy

#signal playerIn
#signal playerOut

@export_category("movement speeds")
var SPEEDS = {
	"idle" : 3.0,
	"approach" : 5.0,
	"lockon" : 0.0,
	"hide" : 7.0
}
@export_category("distances")
@export var DETECTION_RANGE : float = 20.0
@export var COUNTDOWN_RANGE : float = 10.0
@export var HIT_RANGE : float = 15.0
@export var HIDE_RANGE : float = 25.0
@export_category("timer info")
@export var COUNTDOWN : float = 2.0
@export var BREAK_RECOVERY : float = 2.0
@export var PREFIRE : float = 1.0
@export var FIRE_EFFECT_TIME : float = 0.8
@export var DAMAGE_COOLDOWN : float = 0.3
@export var HIDETIME : float = 5.0
@export_category("damage")
@export var DAMAGE : float = 3.0
var playerRef : Player
var originalBasis : Basis

func _ready() -> void:
	vision_radius = DETECTION_RANGE
	attack_radius = HIT_RANGE
	playerRef = GameManager.curr_player
	$Hitbox.damangeAmount = DAMAGE
	$Hitbox.set_disabled(false)
	#$Hitbox.set_disabled(true)#we want the hitbox to be not there at first. actually idk.
	super()
	originalBasis = transform.basis
	
func _physics_process(_delta: float) -> void:
	super(_delta)
	#if $Hitbox.overlaps_body(playerRef):
		#bug here
	#	playerIn.emit()
	#else:
	#	playerOut.emit()
	
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

func resetBasis():
	transform.basis = originalBasis
