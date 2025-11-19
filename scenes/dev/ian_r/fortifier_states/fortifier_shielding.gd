class_name Shielding extends FortifierState


@export var rotate_speed : float = 10
@export var attack_distance : float = 1
var friends: Array[Enemy] = []
const vfx = preload("res://vfx/fortifier_shield_VFX.tscn")
signal shield_enemy


func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	fortifier.velocity = Vector3.ZERO

func update(_delta: float) -> void:
	shield()

func physics_update(delta: float) -> void:
	## goal: have the fortifier face the player while in this state
	var dir : Vector3 = (enemy.global_position - GameManager.curr_player.global_position).normalized().slide(Vector3.UP) * attack_distance
	enemy.rotate_y(enemy.global_basis.z.signed_angle_to(dir, Vector3.UP) * delta * rotate_speed)
	# end of goal

func end() -> void:
	pass
		
func exit() -> void:
	pass
	
func shield():
	if friends.is_empty():
		return
	var enemy = friends.pick_random()
	print("shielding enemy!")
	print(enemy)
	var vfx_instance = vfx.instantiate()
	vfx_instance.global_position = enemy.global_position
	enemy.add_child((vfx_instance))
	enemy.apply_effect(Invincible.new(fortifier))
	if not enemy._status_effects.has(EntityEffect.EffectID.INVINCIBLE):
		shield()
	else:
		shield_enemy.emit()
