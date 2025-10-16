class_name DeadState extends State

@onready var entity : Entity = owner as Entity

@export_category("Animation")
@export var animation : AnimationState

func _ready() -> void:
	entity.killed.connect(func on_death_enter_state(): trigger_finished.emit(get_path()))

func enter(_prev_state: String, _data := {}) -> void:
	entered.emit()
	if (animation): animation.enter()

func end() -> void:
	finished.emit()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
