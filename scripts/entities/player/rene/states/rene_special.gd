@tool
class_name ReneSpecial extends PlayerState

@export var animation: AnimationState

var rene: Rene
@export var speed_scale_factor: float = 1.0
@export var heal_percent: float = 0.5


## Saves instance of Rene as variable
func _ready() -> void:
	super()
	rene = owner as Rene
	assert(rene != null, "Must only be used with Rene")
	
func enter(_prev_state: String, _data := {}) -> void:
	entered.emit()
	if animation != null:
		animation.enter()
		await animation.stop
	else:
		await get_tree().create_timer(0.5).timeout
	end()
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	rene.move(delta, speed_scale_factor)
	rene.move_and_slide()
	
func end() -> void:
	finished.emit()

func exit() -> void:
	get_player_manager().team_heal_percent(heal_percent * rene.damage_mult)
	get_player_manager().team_effect([
		HOT.new(3.0, 1.0 * rene.damage_mult, 3),
		HOT.new(3.0, 1.0 * rene.damage_mult, 3),
		HOT.new(3.0, 1.0 * rene.damage_mult, 3)])
