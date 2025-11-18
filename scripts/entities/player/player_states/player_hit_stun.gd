extends PlayerState

@export var stun_duration: float = 0.1
@export var stun_cooldown: float = 1.0
@export_category("Interruptible States")
@export var interruptible_states: Array[String] = [PlayerState.IDLE, PlayerState.MOVING, PlayerState.CHARGING,
	PlayerState.CHARGING_SPECIAL]

var stun_timer: SceneTreeTimer = null

func _ready() -> void:
	await super()
	player.hurt.connect(_on_hurt_received)

func _on_hurt_received(_damage: float) -> void:
	# Check if current state can be interrupted for hit-stun
	var current_state_name = player.state_machine.state.name

	if current_state_name in interruptible_states and stun_timer == null:
		player.state_machine.state.trigger_finished.emit(get_path())

func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	print("Entering Hit Stun State")

	stun_timer = get_tree().create_timer(stun_duration)
	stun_timer.timeout.connect(end)

	player.velocity = Vector3.ZERO

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.velocity = Vector3.ZERO
	player.move_and_slide()

func end() -> void:
	# it's not going to enter moving state if stunned, unless we implement knockback later
	trigger_finished.emit(MOVING if player.velocity else IDLE)

func exit() -> void:
	if stun_timer != null and stun_timer.timeout.is_connected(end):
		stun_timer.timeout.disconnect(end)
	stun_timer = get_tree().create_timer(stun_cooldown)
	stun_timer.timeout.connect(func(): stun_timer = null)
