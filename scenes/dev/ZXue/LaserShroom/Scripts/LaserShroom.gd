#Laser Shroom implementation code
#Let's also try state machine with this one.

class_name LaserShroom extends Enemy

@export var aimTime:float = 2.0
@export var hideTime:float = 3.0#how long we want lasershroom to do james time
@export var dict_moveSpeed = {
	"idle" : 1.5,
	"approach" : 3.0,
	"lock": 0.8,
	"retreat" : 8.0}

@export var idleMoveTime:float = 2.5


func _init() -> void:
	super()
	var allStates = {#register all the states
		"IDLE" : "idle",
		"APPROACH" : "approach",
		"LOCK ON" : "lockon",
		"AIM" : "aim",
		"FIRE" : "fire",
		"RETREAT": "retreat",
		"HIDE" : "hide",
		"BROKEN" : "broken",
		"DEAD" : "dead"}
	var statePath = "res://scenes/dev/ZXue/FSM/Scenes/"
	$SM_LaserShroom._init()
	

func _physics_process(_delta: float) -> void:
	match $SM_LaserShroom.currentStateName:
		"IDLE":
			_moveset_idle()
		"APPROACH":
			_moveset_approach()
		"LOCK ON":
			_moveset_lockon()
		"AIM":
			_moveset_aim()
		"FIRE":
			_moveset_fire()
		"RETREAT":
			_moveset_retreat()
		"HIDE":
			_moveset_hide()
		"BROKEN":
			_moveset_broken()
		"DEAD":
			_moveset_dead()
		_:
			print("error: State Machine's current state name does not match any of the presets.")
			
				
#DIFFERENT ACTION MECHANISMS FOR DIFFERENT STATES

func _moveset_idle():
	move_and_slide()
	
func _moveset_approach():
	pass
	
func _moveset_lockon():
	pass

func _moveset_aim():
	pass
	
func _moveset_fire():
	pass
	
func _moveset_retreat():
	pass
	
func _moveset_hide():
	pass
	
func _moveset_broken():
	pass
	
func _moveset_dead():
	pass
	
	

#A part of idle moveset
func _on_idle_move_around_timer_timeout() -> void:
	var prevDirectionSet:float = 0.0
	var directionSet:float = randf_range(0.0, 2*PI)
	if(abs(directionSet - prevDirectionSet) < (2.0/3.0)*PI):#we want the mob to walk around when idle.
		directionSet = directionSet + (2.0/3.0)*PI
	prevDirectionSet = directionSet
	#move
	velocity = Vector3.ZERO
	velocity.x = sin(directionSet)
	velocity.y = cos(directionSet)
	velocity = velocity*dict_moveSpeed["idle"]
	$IdleMoveAroundTimer.start(idleMoveTime)
