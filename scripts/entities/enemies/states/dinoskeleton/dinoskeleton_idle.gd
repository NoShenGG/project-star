extends State

var parent_enemy : DinoSkeleton

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_prev_state: String, _data := {}) -> void:
	parent_enemy = owner as DinoSkeleton
	var aggro_area : Area3D = parent_enemy.get_node("AggroArea/Area3D")
	aggro_area.body_entered.connect(_on_aggro_area_body_entered.bind())
	entered.emit()

func _on_aggro_area_body_entered(body: Node3D) -> void:
	if (is_same(body, GameManager.curr_player)):
		parent_enemy.target_node = body
		parent_enemy.chase.emit()
		trigger_finished.emit("chase")

func end() -> void:
	trigger_finished.emit("idle")

func exit() -> void:
	pass
