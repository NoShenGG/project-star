class_name RangedEnemy extends Enemy

const Projectile := preload("res://scenes/sub/RangedWeapon.tscn")
@export var speed = 1
@export var projectile_range = 1;
@export var target_node: Node3D
@onready var cooldown: Timer = $Cooldown
@onready var player_manager: Node3D = $"../PlayerManager"

var target_desired_distance = attack_radius

func _ready():
	#target_node = player_manager
	target_node = null
	navigation_agent.target_desired_distance = target_desired_distance

func recalc_path():
	if (target_node):
		set_movement_target(target_node.global_position)
		
func _on_recalculate_timer_timeout() -> void:
	recalc_path()

func attack() -> void:
	if (target_node && cooldown.is_stopped()):
		shoot(Projectile)
	
func shoot(projectile: PackedScene) -> void:
	var projectile_instance = projectile.instantiate()
	var dir = global_position.direction_to(target_node.global_position)
	projectile_instance.direction = dir
	add_child(projectile_instance)
	cooldown.start()
	is_attacking = false
	
	
func _on_aggro_area_body_entered(body: Node3D) -> void:
	if (body.name.substr(0, 7) == "Player"):
		target_node = body

func _on_cooldown_timeout() -> void:
	if (is_attacking):
		shoot(Projectile)
