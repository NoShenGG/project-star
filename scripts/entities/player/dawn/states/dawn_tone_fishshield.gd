@tool
@icon("uid://cqoaj0qflq6xg")
extends AnimatedOneshotState

@export var _move_speed_factor: float = 0.4
@export var effect_duration: float = 7.0
@export var shield_mesh: MeshInstance3D
@export var shield: Area3D

@onready var dawn: Dawn = owner as Dawn

var active: bool = false

func _ready() -> void:
	assert(dawn != null, "Must only be used with Dawn")

func enter(_prev_state: String, _data := {}) -> void:
	super(_prev_state, _data)
	active = true
	entered.emit()
	await_end()
	

func await_end():
	await animation_finished
	
	if (dawn.death): return
	else: end()

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	dawn.move(delta, _move_speed_factor)
	dawn.move_and_slide()

		

func exit() -> void:
	dawn.apply_effect(Tempo.new(effect_duration, shield_mesh, shield))
	active = false
