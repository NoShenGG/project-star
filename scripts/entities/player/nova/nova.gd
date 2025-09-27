class_name Nova extends Player

signal special_dash(chain: bool)

@onready var slash_box: Area3D = $Hitboxes/Slash
@onready var sweep_box: Area3D = $Hitboxes/Sweep
@onready var poke_box: Area3D = $Hitboxes/Poke
@onready var dash_box: Area3D = $Hitboxes/Dash

@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var anim = $DummyAnimation

@export_category("Damage Values")
@export var attack_dmg: Array[int] = [2, 2, 3, 7, 5]
@export var combo_reset_time: float = 1
@export var charged_attack_dmg: int = 10
@export var special_dmg: int = 25
@export_category("Special")
@export var max_charges: int = 3
@export var release_pause: float = 0.5
@export var special_dash_dist: float = 10


# Collision Map: 1-World, 2-Hitboxes, 3-PlayerHurt, 4-EnemyHurt

'''
This class mostly holds special configuration Nova,
and will eventually handle signal binding between states and animation/VFX.

Signals:
	special_dash - Bind to animation/vfx method, it called when player dashes for special.
	
Animation Signals:
	nova_attack, nova_attack_charged both need to bind methods to animation signals
'''

## Signal Binding Mostly
func _ready() -> void:
	special_dash.connect(anim.special_dash)
	
	state_machine.attacking.connect(anim.attack)
	anim.attack_hit.connect(state_machine.get_node(PlayerState.ATTACKING).do_damage)
	anim.attack_done.connect(state_machine.get_node(PlayerState.ATTACKING).end)
	
	state_machine.attacking_charged.connect(anim.attack_charged)
	anim.attack_charged_hit.connect(state_machine.get_node(PlayerState.ATTACKING_CHARGED).do_damage)
	anim.attack_charged_done.connect(state_machine.get_node(PlayerState.ATTACKING_CHARGED).end)
