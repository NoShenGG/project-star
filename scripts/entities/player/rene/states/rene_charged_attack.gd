@tool
class_name ReneCharged extends PlayerState

@export var animation: AnimationState

const vfx = preload("res://scenes/dani_k/Rene_CA_VFX1.tscn")

var rene: Rene
var enemy: Enemy
var oldspd: float
@export var hitbox: Area3D
@export var speed_scale_factor: float = 1.0
@export var heal: float = 3.0
@export var damage: float = 3.0

## Saves instance of Rene as variable
func _ready() -> void:
	super()
	rene = owner as Rene
	assert(rene != null, "Must only be used with Rene")
	
func enter(_prev_state: String, _data := {}) -> void:
	entered.emit()
	var enemies = rene.targetting_box.get_overlapping_bodies() \
			.filter(func(b): return b is Enemy)
	enemies.sort_custom(func(a: Node3D,b: Node3D): \
				return a.global_position.distance_to(rene.global_position) < b.global_position.distance_to(rene.global_position))
	enemy = enemies.pop_front()
	animation.enter()
	animation.stop.connect(end)
	if enemy != null:
		var effect = vfx.instantiate()
		enemy.add_child(effect)
		oldspd =  enemy._base_speed
		enemy._base_speed = 0
		effect.finished.connect(func(): if enemy != null: enemy._base_speed = oldspd)
		hitbox.transform = enemy.global_transform
		hitbox.monitoring = true
		await get_tree().physics_frame
		enemies = hitbox.get_overlapping_bodies().filter(func(b): return b is Enemy)
		for thing: Enemy in enemies:
			thing.try_damage(damage * rene.damage_mult * pow(1.2, rene.counters))
		hitbox.monitoring = false
	
func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	rene.move(delta, speed_scale_factor)
	rene.move_and_slide()
	
func end() -> void:
	trigger_finished.emit("Moving")

func exit() -> void:
	rene.try_heal(heal * rene.damage_mult * pow(1.2, rene.counters))
	rene.counters = 0
	finished.emit()
