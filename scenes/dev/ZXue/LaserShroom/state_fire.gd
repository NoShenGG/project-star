extends EnemyState

var _playerInHitbox : bool = false
var _canMakeDamage : bool = false

@export_category("Properties")
@export var prefire : float = 1.0
@export var fire_effect_time : float = 0.8
@export var damage_cooldown : float = 0.3
@export var damage : float = 3.0
@export_category("Next States")
@export var post_fire_state : State


## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:	
	if $"../../Hitbox".overlaps_body(enemy.player_ref):
		#bug
		_playerInHitbox = true
	else:
		_playerInHitbox = false
	
	if _canMakeDamage:
		if(_playerInHitbox):
			enemy.player_ref.try_damage(damage)
			_canMakeDamage = false
			$DamageCooldownTimer.start(damage_cooldown)

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	print("[LaserShroom]Entering state: FIRE")
	enemy.switchMesh(1)
	enemy.set_movement_target(enemy.global_position)#not to move
	get_node("FireTimer").start(prefire)
	entered.emit()

## Call for another script to end this state. Should pick the next state and emit trigger_finished.
func end() -> void:
	trigger_finished.emit(post_fire_state.get_path())
	
## Called on state exit
func exit() -> void:
	pass

#when timer is out, LaserShroom goes back to hiding.
func _on_fire_timer_timeout() -> void:
	enemy.switchMesh(2)
	_canMakeDamage = true
	#lasershroom.setHitboxStatus(true)
	$FireEffectTimer.start(fire_effect_time)

#detect player_ref in Hitbox
'''
func _on_laser_shroom_player_in() -> void:
	playerInHitbox = true

func _on_laser_shroom_player_out() -> void:
	playerInHitbox = false
	
'''
func _on_damage_cooldown_timer_timeout() -> void:
	_canMakeDamage = true

func _on_fire_effect_timer_timeout() -> void:
	trigger_finished.emit(post_fire_state.get_path())
