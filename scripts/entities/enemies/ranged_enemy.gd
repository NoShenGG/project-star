class_name RangedEnemy extends Enemy

const Projectile := preload("res://scenes/sub/RangedWeapon.tscn")
@export var speed = 1
@export var projectile_range = 1;
@export var target_node: Node3D
@onready var cooldown: Timer = $Cooldown

var target_desired_distance = attack_radius

func _ready():
	target_node = null
	navigation_agent.target_desired_distance = target_desired_distance
