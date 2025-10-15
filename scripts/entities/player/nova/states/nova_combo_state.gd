class_name NovaComboState extends ComboState

var nova: Nova
var active: bool
@export var hitbox: Area3D


## Saves instance of Nova as variable
func _ready() -> void:
	super()
	nova = owner as Nova
	assert(nova != null, "Must only be used with Nova")
	
func enter(_prev_state: String, _data := {}) -> void:
	super(_prev_state, _data)
	hitbox.monitoring = true
	active = true

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if nova.closest_enemy != null:
		nova.move_to(nova.closest_enemy.global_position, delta, 0.1)
	else:
		player.velocity = Vector3.ZERO
	player.move_and_slide()
	
func do_damage() -> void:
	if not hitbox.monitorable or not active:
		return
	for node in hitbox.get_overlapping_bodies():
		if node is Enemy:
			(node as Enemy).try_damage(player.attack_dmg[combo_num])	

func end() -> void:
	if not active:
		return
	super()
	
func exit() -> void:
	active = false
	hitbox.monitoring = false
