extends EnemyState

@export_category("Properties")
@export var rotate_speed : float = 10.0
@export var detection_range = 20.0
@export_category("Next States")
@export var lost_track_state : State
@export var post_lock_state : State

var _running : bool
var _turning: bool

func _ready() -> void:
	$LockTimer.timeout.connect(lock_target)
	$HoldTimer.timeout.connect(func(): trigger_finished.emit(post_lock_state.get_path()))
	super()

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	#thank u Fire555 for the rotation code
	if _turning:
		var dir : Vector3 = (enemy.global_position - GameManager.curr_player.global_position).normalized().slide(Vector3.UP)
		enemy.rotate_y(enemy.global_basis.z.signed_angle_to(dir, Vector3.UP) * _delta * rotate_speed)
		
	#update
	var distanceToPlayer:float = enemy.global_position.distance_to(enemy.player_ref.global_position)
	if(distanceToPlayer > detection_range):
		$LockTimer.stop()
		$HoldTimer.stop()
		enemy.switchMesh(0)
		trigger_finished.emit(lost_track_state.get_path())

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	print("[LaserShroom]Entering state: LOCKON")
	entered.emit()
	$LockTimer.start()
	enemy.switchMesh(1)
	enemy.set_movement_target(enemy.global_position)
	_running = true
	_turning = true
	
func end():
	pass

	
## Called on state exit
func exit() -> void:
	_running = false

#when timer goes out, LaserShroom will fire.
func lock_target() -> void:
	if (!_running): return
	$HoldTimer.start()
	_turning = false
	
