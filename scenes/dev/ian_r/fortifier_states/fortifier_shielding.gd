class_name Shielding extends FortifierState


var friends: Array[Enemy] = []
signal shield_enemy


func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	fortifier.velocity = Vector3.ZERO

func update(_delta: float) -> void:
	shield()

func physics_update(delta: float) -> void:
	## goal: have the fortifier face the player while in this state
	pass

func end() -> void:
	pass
		
func exit() -> void:
	pass
	
func shield():
	if friends.is_empty():
		return
	var enemy = friends.pick_random()
	print(enemy)
	enemy.apply_effect(Invincible.new(fortifier))
	if not enemy._status_effects.has(EntityEffect.EffectID.INVINCIBLE):
		shield()
	else:
		shield_enemy.emit()
