class_name DeadState extends State

@onready var entity : Entity = owner as Entity

## when entering, should we snap our rotation to look at the player (who killed us)
@export var snap_turn_to_player : bool

@export_category("Animation")
@export var animation : AnimationState

func _ready() -> void:
	entity.killed.connect(func on_death_enter_state(): trigger_finished.emit(get_path()))

func enter(_prev_state: String, _data := {}) -> void:
	entered.emit()
	entity.velocity = Vector3.ZERO
	if (animation): animation.enter()
	
	if (snap_turn_to_player):
		var dir : Vector3 = (owner.global_position - GameManager.curr_player.global_position).normalized().slide(Vector3.UP)
		owner.rotate_y(owner.global_basis.z.signed_angle_to(dir, Vector3.UP))


func end() -> void:
	finished.emit()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
