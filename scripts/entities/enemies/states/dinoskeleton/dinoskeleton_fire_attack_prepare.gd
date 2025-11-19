extends State

var parent_enemy : DinoSkeleton

@onready var anticipation_timer: Timer = $FireAnticipationTimer

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_prev_state: String, _data := {}) -> void:
	parent_enemy = owner as DinoSkeleton
	
	if parent_enemy.target_node == null:
		trigger_finished.emit("chase")
		return
	
	if parent_enemy.fire_anticipation_scene:
		var anticipation = parent_enemy.fire_anticipation_scene.instantiate()
		anticipation.global_position = parent_enemy.global_position
		parent_enemy.get_tree().current_scene.add_child(anticipation)

	parent_enemy.fire_prepare.emit()
	
	if not anticipation_timer.timeout.is_connected(_on_anticipation_done):
		anticipation_timer.timeout.connect(_on_anticipation_done)
	anticipation_timer.start()
	
	entered.emit()

func _on_anticipation_done() -> void:
	trigger_finished.emit("fire_attack_commit")

func end() -> void:
	if anticipation_timer and anticipation_timer.is_stopped() == false:
		anticipation_timer.stop();
	trigger_finished.emit("chase")

func exit() -> void:
	if anticipation_timer and anticipation_timer.timeout.is_connected(_on_anticipation_done):
		anticipation_timer.timeout.disconnect(_on_anticipation_done)
