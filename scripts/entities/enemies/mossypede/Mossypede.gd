class_name Mossypede extends Enemy

@export var attack_cd: float = 1.0
@export var hit_dmg: float = 1.0
@export var knockback: float = 1.0

var can_damage: bool = true

func _process(delta: float) -> void:
	super(delta)
	if can_damage and \
			global_position.distance_to(GameManager.curr_player.global_position) \
			< attack_radius:
		can_damage = false
		var player = GameManager.curr_player
		player.try_damage(hit_dmg * damage_mult)
		if state_machine.state.name == "Attacking":
			var state = player.state_machine.state
			if state.name == "Dash":
				state.trigger_finished.emit("Moving")
			player.global_position += global_position.direction_to(player.global_position) * knockback
		get_tree().create_timer(attack_cd).timeout.connect(func(): can_damage = true)

func trigger_death():
	super()
	state_machine.state.trigger_finished.emit("Dead")
