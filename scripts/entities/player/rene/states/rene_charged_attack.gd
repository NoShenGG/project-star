@tool
class_name ReneCharged extends PlayerState

@export var animation: AnimationState

var rene: Rene
@export var speed_scale_factor: float = 1.0
@export var heal: float = 10.0


## Saves instance of Rene as variable
func _ready() -> void:
	super()
	rene = owner as Rene
	assert(rene != null, "Must only be used with Rene")
	
func enter(_prev_state: String, _data := {}) -> void:
	entered.emit()
	animation.enter()
	await animation.stop
	end()
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	rene.move(delta, speed_scale_factor)
	rene.move_and_slide()
	
func end() -> void:
	trigger_finished.emit("Moving")

func exit() -> void:
	team_heal(heal * rene.damage_mult * pow(1.2, rene.counters))
	rene.counters = 0
	finished.emit()
