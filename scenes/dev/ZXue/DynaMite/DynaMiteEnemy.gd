class_name Dynamite extends Enemy

@export_category("rotation")
@export var ROTATION_SPEED : float = 60
@export_category("movement speeds")
var SPEEDS = {
	"idle" : 3.0,
	"approach" : 5.0,
	"broken" : 7.0
}
@export_category("distances")
@export var DETECTION_RANGE : float = 20.0
@export var COUNTDOWN_RANGE : float = 10.0
@export_category("timer info")
@export var COUNTDOWN : float = 2.0
@export var BREAK_RECOVERY : float = 2.0
@export_category("damage")
@export var DAMAGE : float = 1.0
var playerRef : Player:
	get():
		return GameManager.curr_player

func _ready() -> void:
	$Hitbox.damangeAmount = DAMAGE
	$Hitbox.set_disabled(true)#we want the hitbox to be not there at first.
	super()
