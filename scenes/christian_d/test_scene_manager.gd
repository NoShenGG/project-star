## Attach to Prototype in COPY_THIS to test mind merger.
extends Node3D

var enemies: Array[Enemy] = []
var mergers: Array[MindMerger] = []

func _ready() -> void:
	for i in range(6):
		spawn_enemy()
	spawn_merge()
	
func spawn_enemy() -> void:
	var enemy = load("res://scenes/christian_d/TestEnemy.tscn").instantiate()
	enemy.position = Vector3(randi_range(2, 10)*(-1 if randf() > 0.5 else 1), 2, randi_range(2, 10)*(-1 if randf() > 0.5 else 1))
	add_child(enemy)
	enemies.append(enemy)
	
func spawn_merge() -> void:
	var spawn_position = Vector3(5, 5, -3)
	enemies.sort_custom(func(a,b): return (a.global_position.distance_to(spawn_position)) < b.global_position.distance_to(spawn_position))
	var to_merge = enemies.filter(func(a): return not (a as MergerTestEnemy)._status_effects.has(EntityEffect.EffectID.MERGED)).slice(0, 6)
	var merger = load("res://scenes/christian_d/MindMerger.tscn").instantiate()
	merger.setup($Player, to_merge.size())
	merger.position = spawn_position
	for i in range(len(to_merge)):
		(to_merge[i] as Enemy).apply_effect(Merged.new(merger, i))
	add_child(merger)
	mergers.append(merger as MindMerger)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("select_char1"):
		spawn_enemy()
	if Input.is_action_just_pressed("select_char2"):
		var index = randi_range(0, enemies.size()-1)
		var selected = enemies[index]
		enemies.remove_at(index)
		(selected as MergerTestEnemy).trigger_death()
	if Input.is_action_just_pressed("select_char3"):
		var index = randi_range(0, mergers.size()-1)
		var selected = mergers[index]
		mergers.remove_at(index)
		(selected as MindMerger).trigger_death()
	if Input.is_action_just_pressed("special_attack"):
		spawn_merge()
