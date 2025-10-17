@tool
@icon("uid://cqoaj0qflq6xg")
class_name NovaSpecialWait extends AnimatedOneshotState

var active: bool
var nova: Nova


## Saves instance of Nova as variable
func _ready() -> void:
	nova = owner as Nova
	assert(nova != null, "Must only be used with Nova")

func enter(_prev_state: String, _data := {}) -> void:
	super(_prev_state, _data)
	active = true
	entered.emit()
	
	await_end()

func await_end():
	await animation_finished
	exit()

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction := Input.get_vector("move_up", "move_down", "move_right", "move_left")
	
	direction = direction.rotated(deg_to_rad(45))
	
	nova.target_velocity.x = direction.x
	nova.target_velocity.z = direction.y
	
	nova.look_at(nova.global_position + 
			nova.target_velocity.lerp(
				Vector3.FORWARD.rotated(Vector3.UP, nova.rotation.y),
				clamp(pow(0.1, 2 * nova.input_smoothing_speed * delta), 0, 1)))


func end() -> void:
	if not active:
		return
	super()

func exit() -> void:
	active = false
	finished.emit()
