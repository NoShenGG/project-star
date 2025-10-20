extends PlayerState

@export var stun_duration: float = 0.5
# TODO connect to animation state

var stun_timer: float = 0.0

func _ready() -> void:
	super()
	await owner.ready
	# Connect to hurt signal, similar to death.gd
	player.hurt.connect(func on_hurt_enter_state(_damage: float): 
		# Check if current state can be interrupted for hit-stun
		var current_state_name = player.state_machine.state.name
		var interruptible_states = [PlayerState.IDLE, PlayerState.MOVING, PlayerState.CHARGING, PlayerState.CHARGING_SPECIAL]
		
		if current_state_name in interruptible_states:
			player.state_machine.state.trigger_finished.emit(get_path())
	)

func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	print("Entering Hit Stun State")
	
	stun_timer = 0.0
	player.velocity = Vector3.ZERO
	
	# # Play hit-stun animation if available
	# if hit_stun_animation:
	# 	hit_stun_animation.enter()

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	stun_timer += delta
	
	player.velocity = Vector3.ZERO
	
	player.move_and_slide()
	
	if stun_timer >= stun_duration:
		trigger_finished.emit(IDLE)

func end() -> void:
	pass

func exit() -> void:
	player.velocity = Vector3.ZERO