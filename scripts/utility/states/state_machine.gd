class_name StateMachine extends Node

signal state_entered(state: String)
signal state_exited(state: String)

@export var initial_state: State = null

@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()


func _ready() -> void:
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)

	await owner.ready
	state.enter("")


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


## Moves between states. Calls emits exit and enter signals before states execute their functions.
func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return
	var previous_state_path := state.name
	state_exited.emit(state.name)
	state.exit()
	state = get_node(target_state_path)
	state_entered.emit(state.name)
	state.enter(previous_state_path, data)
