class_name Fortifier extends Enemy


@export var recalc_cd: float = 2.0
@export var attack_cd: float = 1.0
@export var vision: Area3D


func _ready() -> void:
	super()
	await get_tree().process_frame
	await get_tree().process_frame
	shield()
		
func shield() -> bool:
	var enemy = vision.get_overlapping_bodies().filter(
		func(a): return a is Enemy and a != self).pick_random()
	if enemy == null:
		return false
	enemy.apply_effect(FortifierInvincible.new(self))
	return true
		
func reset_shield():
	state_machine.state.trigger_finished.emit("Shielding")
