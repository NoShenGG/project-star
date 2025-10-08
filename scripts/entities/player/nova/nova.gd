class_name Nova extends Player

@onready var slash_box: Area3D = $Hitboxes/Slash
@onready var sweep_box: Area3D = $Hitboxes/Sweep
@onready var poke_box: Area3D = $Hitboxes/Poke
@onready var dash_box: Area3D = $Hitboxes/Dash

@onready var anim = $DummyAnimation

@export_category("Damage Values")
@export var attack_dmg: Array[int] = [2, 2, 3, 7, 5]
@export var combo_reset_time: float = 1
@export var charged_attack_dmg: int = 10
@export var special_dmg: int = 25
@export_category("Nova Special")
@export var release_pause: float = 0.5
@export var special_dash_dist: float = 10



'''
This class mostly holds configuration for Nova.
It may eventually hold some signal binding or wtv.
'''

## Signal Binding Mostly
func _ready() -> void:
	$ForwardRay.target_position = Vector3.FORWARD * max(special_dash_dist, dash_distance)
