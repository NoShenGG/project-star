## Test Enemy to be controlled by Mind Merger
class_name MergerTestEnemy extends Enemy

@export var SPEED: float = 7
@export var MERGED_SPEED: float = 15
@export var SLOW_DIST: float = 1

signal killed(n: int)

var player: CharacterBody3D
var merger: MindMerger
var merged: int = -1
var target: Vector3


# Updates Movement Target if Not Merged
func _process(delta: float) -> void:
	target = player.global_position if merged == -1 else target

# Updates Movement Target with Vec3 dictated by Merger
func _merge_get_target(pos: Array[Vector3]) -> void:
	if merged != -1:
		target = pos[merged]

# Used to Re-Index Minion
func merge_num_update(n: int) -> void:
	merged = n
	return
	
# Configures Minons to merge with Merger
func merge_with(_merger: MindMerger, n: int) -> void:
	merged = n
	merger = _merger
	merger.update.connect(_merge_get_target)
	merger.killed.connect(unmerge)
	
# Unconfigures Minions to be Merged
func unmerge() -> void:
	if merger != null:
		merger.update.disconnect(_merge_get_target)
		merger.killed.disconnect(unmerge)
	merged = -1
	
# On Minion Death, alert Merger to remove this from its list of Minions
func kill() -> void:
	if merger != null:
		merger.update.disconnect(_merge_get_target)
		merger.killed.disconnect(unmerge)
	killed.emit(merged)
	merged = -1
	self.queue_free()

# Execute Movement to Target
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var err = (target-global_position)
	var speed = SPEED if merged == -1 else MERGED_SPEED
	err = err.lerp(Vector3.ZERO, 1-err.length()/SLOW_DIST)*speed if err.length() < SLOW_DIST else err.normalized()*speed
	state.linear_velocity = Vector3(err.x, -1, err.z)
	state.angular_velocity = Vector3.ZERO
	
