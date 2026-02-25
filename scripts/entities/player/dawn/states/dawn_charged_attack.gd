@tool
extends AnimatedOneshotState

@export var _move_speed_factor: float = 0.4
@export var hitbox: Area3D
@export var damage : float = 2

@onready var dawn: Dawn = owner as Dawn


## Saves instance of Dawn as variable
func _ready() -> void:
	dawn = owner as Dawn
	assert(dawn != null, "Must only be used with Dawn")
	
func enter(_prev_state: String, _data := {}) -> void:
	super(_prev_state, _data)
	hitbox.monitoring = true	
	if dawn.closest_enemy != null:
		var target = dawn.closest_enemy.global_position
		dawn.look_at(Vector3(target.x, dawn.global_position.y, target.z))
	entered.emit()
	do_damage()
	await_end()
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func await_end():
	await animation_finished
	
	if (dawn.death): return
	trigger_finished.emit(PlayerState.MOVING if dawn.velocity else PlayerState.IDLE)

func do_damage() -> void:
	await get_tree().physics_frame
	if not hitbox.monitoring or dawn.death:
		return
	
	for node in hitbox.get_overlapping_bodies():
		if node is Entity and (node as Entity).faction != dawn.faction:
			if (node as Entity).try_damage(damage):
				dawn.note_manager.add_white()
			

func exit() -> void:
	hitbox.monitoring = false
	finished.emit()
