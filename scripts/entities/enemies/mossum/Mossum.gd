class_name Mossum extends Enemy


@export var recalc_cd: float = 2.0
@export var attack_cd: float = 2.0
@export var hit_dmg: float = 1.0

var target: Player = null
var can_attack: bool = true

signal mossum_attack
	

func recalc_path():
	if (target):
		set_movement_target(target.global_position)
		get_tree().create_timer(recalc_cd).timeout.connect(recalc_path)
		

func _process(_delta: float) -> void:
	super(_delta)
	if target and can_attack and \
			global_position.distance_to(target.global_position) < attack_radius \
			and not death:
		mossum_attack.emit()
		target.try_damage(hit_dmg)
		can_attack = false
		get_tree().create_timer(attack_cd).timeout.connect(func(): can_attack = true)
	var dir : Vector3 = (global_position - GameManager.curr_player.global_position).normalized().slide(Vector3.UP)
	rotate_y(global_basis.z.signed_angle_to(dir, Vector3.UP) * _delta * 10)


func _on_aggro_body_entered(body: Node3D) -> void:
	if body is Player:
		can_attack = true
		target = body as Player
		recalc_path()


func _on_aggro_body_exited(body: Node3D) -> void:
	if body is Player:
		target = null
		set_movement_target(global_position)
