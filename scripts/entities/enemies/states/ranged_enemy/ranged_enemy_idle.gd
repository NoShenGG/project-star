extends State

var parent_enemy : RangedEnemy

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_prev_state: String, _data := {}) -> void:
	parent_enemy = owner as RangedEnemy
	var aggro_area : Area3D = parent_enemy.get_node("AggroArea/Area3D")
	aggro_area.body_entered.connect(_on_aggro_area_body_entered.bind())
	entered.emit()

func _on_aggro_area_body_entered(body: Node3D) -> void:
	print(body)
	if (is_same(body, GameManager.curr_player)):
		parent_enemy.target_node = body
		trigger_finished.emit("attacking")

func end() -> void:
	trigger_finished.emit("attacking")

func exit() -> void:
	pass
