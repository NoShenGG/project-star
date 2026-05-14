extends EnemyState

@export var fire_node : Node3D
@export var projectile: PackedScene
@export var done_state: State
@export_category("Windup Stage")
@export var windup_time: float = 1
@export var windup_anim: AnimationState = null
@export var windup_rotate_player: bool = true
@export var windup_rotate_speed : float = 5
@export_category("Fire Stage")
@export var fire_time: float = 1
@export var fire_anim: AnimationState = null
@export var bullet_delay: float = 0.2
@export var fire_rotate_player: bool = true
@export var fire_rotate_speed : float = 5

## called when firing with aiming direction
signal fired

var rotating: bool = false
var rotation_speed = 0


func update(_delta: float) -> void:
	if not rotating:
		return
	var dir : Vector3 = (enemy.global_position - GameManager.curr_player.global_position).normalized().slide(Vector3.UP)
	enemy.rotate_y(enemy.global_basis.z.signed_angle_to(dir, Vector3.UP) * _delta * rotation_speed)
	
func physics_update(_delta: float) -> void:
	pass

func enter(_prev_state: String, _data := {}) -> void:
	if windup_anim != null:
		windup_anim.enter()
	entered.emit()
	if windup_time > 0:
		rotating = true
		rotation_speed = windup_rotate_speed
		get_tree().create_timer(windup_time).timeout.connect(fire)
	else:
		fire()

func fire() -> void:
	if enemy.death:
		return
	if fire_anim != null:
		fire_anim.enter()
	
	if fire_time > 0:
		rotating = true
		rotation_speed = fire_rotate_speed
		get_tree().create_timer(fire_time).timeout.connect(end)
	else:
		rotating = false
		end()
		return
		
	if bullet_delay > 0:
		get_tree().create_timer(bullet_delay).timeout.connect(shoot)
	else:
		shoot()

func shoot() -> void:
	var projectile_instance = enemy.projectile_scene.instantiate()
	projectile_instance.global_transform = fire_node.global_transform
	var dir : Vector3 = enemy.global_position.direction_to(GameManager.curr_player.global_position)
	dir.y = 0
	projectile_instance.direction = dir
	enemy.add_child(projectile_instance)
	fired.emit()

func end() -> void:
	trigger_finished.emit(done_state.get_path())

func exit() -> void:
	pass
 
