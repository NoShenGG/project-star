@tool
class_name ReneComboState extends AnimatedOneshotState

@export var bullet: PackedScene

var rene: Rene
@export var speed_scale_factor: float = 0.5
@export var damage: float = 1.0


## Saves instance of Rene as variable
func _ready() -> void:
	rene = owner as Rene
	assert(rene != null, "Must only be used with Rene")
	
func enter(_prev_state: String, _data := {}) -> void:
	super(_prev_state, _data)
	var shot = bullet.instantiate() as ReneShot
	if rene.closest_enemy != null:
		shot.target = rene.closest_enemy
	shot.global_transform = rene.global_transform
	shot.damage = damage * rene.damage_mult
	shot.hit.connect(func(): rene.counters += 1)
	shot.hit.connect(rene.enemy_hit.emit)
	rene.add_child(shot)
	await animation_finished
	end()
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if rene.closest_enemy != null:
		var target = rene.closest_enemy.global_position
		rene.look_at(Vector3(target.x, rene.global_position.y, target.z))
		rene.move_translate(delta, speed_scale_factor)
	else:
		rene.move(delta, speed_scale_factor)
	rene.move_and_slide()
	
func end() -> void:
	finished.emit()
	
func exit() -> void:
	pass
