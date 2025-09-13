## Attach to Prototype in COPY_THIS to test mind merger.
extends Node3D

var enemies: Array[RigidBody3D] = []
var mergers: Array[MindMerger] = []

func _ready() -> void:
	for i in range(6):
		spawn_enemy()
	spawn_merge()
	
func spawn_enemy() -> void:
	var enemy = load("res://scenes/christian_d/TestEnemy.tscn").instantiate()
	enemy.player = $PlayerManager/Player
	enemy.position = Vector3(randi_range(2, 10)*(-1 if randf() > 0.5 else 1), 2, randi_range(2, 10)*(-1 if randf() > 0.5 else 1))
	add_child(enemy)
	enemies.append(enemy)
	
func spawn_merge() -> void:
	var merger = load("res://scenes/christian_d/MindMerger.tscn").instantiate() as MindMerger
	merger.position = Vector3(5, 3, -3)
	merger.player = $PlayerManager/Player
	add_child(merger)
	enemies.sort_custom(func(a,b): return (a.global_position.distance_to(merger.global_position)) < b.global_position.distance_to(merger.global_position))
	merger.setup(enemies.filter(func(a): return (a as MergerTestEnemy).merged == -1).slice(0, 6))
	mergers.append(merger as MindMerger)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("select_char1"):
		spawn_enemy()
	if Input.is_action_just_pressed("select_char2"):
		var index = randi_range(0, enemies.size()-1)
		var selected = enemies[index]
		enemies.remove_at(index)
		(selected as MergerTestEnemy).kill()
	if Input.is_action_just_pressed("select_char3"):
		var index = randi_range(0, mergers.size()-1)
		var selected = mergers[index]
		mergers.remove_at(index)
		(selected as MindMerger).kill()
	if Input.is_action_just_pressed("special_attack"):
		spawn_merge()
