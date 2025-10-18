extends State

var lasershroom : LaserShroom
var playerInHitbox : bool = false
var canMakeDamage : bool = false

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:	
	if $"../../Hitbox".overlaps_body(lasershroom.playerRef):
		#bug
		playerInHitbox = true
	else:
		playerInHitbox = false
	
	if canMakeDamage:
		if(playerInHitbox):
			lasershroom.playerRef.try_damage(lasershroom.DAMAGE)
			canMakeDamage = false
			$DamageCooldownTimer.start(lasershroom.DAMAGE_COOLDOWN)
	
	#update
	if(lasershroom._hp <= 0):
		trigger_finished.emit("dead")

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	print("[LaserShroom]Entering state: FIRE")
	lasershroom = owner as LaserShroom
	lasershroom.set_movement_target(lasershroom.global_position)#not to move
	get_node("FireTimer").start(lasershroom.PREFIRE)
	entered.emit()

## Call for another script to end this state. Should pick the next state and emit trigger_finished.
func end() -> void:
	trigger_finished.emit("hide")
	
## Called on state exit
func exit() -> void:
	pass

#when timer is out, LaserShroom goes back to hiding.
func _on_fire_timer_timeout() -> void:
	lasershroom.switchMesh(2)
	canMakeDamage = true
	#lasershroom.setHitboxStatus(true)
	$FireEffectTimer.start(lasershroom.FIRE_EFFECT_TIME)

#detect playerRef in Hitbox
'''
func _on_laser_shroom_player_in() -> void:
	playerInHitbox = true

func _on_laser_shroom_player_out() -> void:
	playerInHitbox = false
	
'''
func _on_damage_cooldown_timer_timeout() -> void:
	canMakeDamage = true

func _on_fire_effect_timer_timeout() -> void:
	trigger_finished.emit("hide")
