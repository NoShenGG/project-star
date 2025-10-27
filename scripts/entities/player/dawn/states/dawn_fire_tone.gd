@tool
@icon("uid://cqoaj0qflq6xg")
class_name DawnFireNote extends AnimatedOneshotState

signal fire

@export var _move_speed_factor: float = 0.4
@export var fire_delay: float = 0.2
@export var auto_aim: bool = true
## when the player gets too far from the enemy, interrupts wait
@export var finished_state : State

@onready var dawn: Dawn = owner as Dawn

var active: bool = false

func _ready() -> void:
	assert(dawn != null, "Must only be used with Nova")

func enter(_prev_state: String, _data := {}) -> void:
	super(_prev_state, _data)
	active = true
	entered.emit()
	get_tree().create_timer(fire_delay).timeout.connect(fire.emit)
	await_end()
	

func await_end():
	await animation_finished
	
	if (dawn.death): return
	if (finished_state): trigger_finished.emit(finished_state.get_path())
	else: exit()

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if auto_aim and dawn.closest_enemy != null:
		var target = dawn.closest_enemy.global_position
		dawn.look_at(Vector3(target.x, dawn.global_position.y, target.z))
		dawn.move_translate(delta, _move_speed_factor)
	else:
		dawn.move(delta, _move_speed_factor)
	dawn.move_and_slide()

func end() -> void:
	super()
	if not active:
		return
	finished.emit()

func exit() -> void:
	active = false
	finished.emit()
