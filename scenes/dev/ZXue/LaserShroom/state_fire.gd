extends EnemyState

@export var hitbox: Area3D
@export_category("Properties")
@export var fire_time : float = 0.8
@export var damage_cooldown : float = 0.3
@export var damage : float = 3.0
@export_category("Next States")
@export var post_fire_state : State

var _running
var dmg_timer: SceneTreeTimer

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	if(_running and hitbox.monitoring and !enemy.death and dmg_timer == null):
		dmg_timer = get_tree().create_timer(damage_cooldown)
		dmg_timer.timeout.connect(func(): dmg_timer = null)
		for node in hitbox.get_overlapping_bodies():
			if node is Entity and (node as Entity).faction == enemy.player_ref.faction:
				(node as Entity).try_damage(damage * enemy.damage_mult)

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	print("[LaserShroom]Entering state: FIRE")
	enemy.switchMesh(2)
	enemy.set_movement_target(enemy.global_position)#not to move
	get_tree().create_timer(fire_time).timeout.connect(end)
	hitbox.monitoring = true
	_running = true
	entered.emit()

## Call for another script to end this state. Should pick the next state and emit trigger_finished.
func end() -> void:
	trigger_finished.emit(post_fire_state.get_path())
	_running = false

## Called on state exit
func exit() -> void:
	enemy.switchMesh(0) # VFX Off
	hitbox.monitoring = false # Hitbox Off
	
