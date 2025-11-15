class_name Fortifier extends Enemy


@export var recalc_cd: float = 2.0
@export var attack_cd: float = 1.0

var target: Player = null
var friends: Array[Enemy] = []
var can_attack: bool = true

signal shield_enemy


func recalc_path():
	if (target):
		set_movement_target(target.global_position)
		get_tree().create_timer(recalc_cd).timeout.connect(recalc_path)
		
func shield():
	if friends.is_empty():
		reset_shield()
		return
	var enemy = friends.pick_random()
	print(enemy)
	enemy.apply_effect(Invincible.new(self))
	if not enemy._status_effects.has(EntityEffect.EffectID.INVINCIBLE):
		shield()
	else:
		shield_enemy.emit()
		
func reset_shield():
	get_tree().create_timer(attack_cd).timeout.connect(func(): can_attack = true)

func _process(_delta: float) -> void:
	super(_delta)
	if can_attack:
		shield_enemy.emit()
		shield()
		can_attack = false
		


func _on_aggro_body_entered(body: Node3D) -> void:
	if body is Player:
		target = body as Player
		recalc_path()


func _on_aggro_body_exited(body: Node3D) -> void:
	if body is Player:
		target = null
		set_movement_target(global_position)
		

func _on_shield_body_entered(body: Node3D) -> void:
	if body is Enemy and not body is Fortifier:
		friends.append(body as Enemy)


func _on_shield_body_exited(body: Node3D) -> void:
	if body is Enemy and not body is Fortifier:
		friends.erase(body as Enemy)
		if (body as Enemy)._status_effects.has(EntityEffect.EffectID.INVINCIBLE):
			body._status_effects.get(EntityEffect.EffectID.INVINCIBLE).active = false
			reset_shield()
