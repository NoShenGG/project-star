@tool
class_name MeleeAttackState extends AnimatedOneshotState

var active: bool
@export var hitbox: Area3D
@export var damage : float = 2

## when entering should we call do_damage()
@export var damage_on_enter : bool


## when the player gets too far from the enemy, interrupts wait
@export var finished_state : State

@onready var entity : Entity = owner as Entity

func enter(_prev_state: String, _data := {}) -> void:
	super(_prev_state, _data)
	hitbox.monitoring = true
	active = true
	entered.emit()
	if (damage_on_enter):
		do_damage()
	
	await_end()

func await_end():
	await animation_finished
	
	if (entity.death): return
	if (finished_state): trigger_finished.emit(finished_state.get_path())
	else: exit()

func update(_delta: float) -> void:
	pass

func physics_update(_delta : float):
	pass

func do_damage() -> void:
	if not hitbox.monitoring or not active or entity.death:
		return
	
	for node in hitbox.get_overlapping_bodies():
		if node is Entity and (node as Entity).faction != entity.faction:
			(node as Entity).try_damage(damage)

func end() -> void:
	super()
	if not active:
		return
	finished.emit()

func exit() -> void:
	active = false
	hitbox.monitoring = false
	finished.emit()
