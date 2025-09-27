class_name Fortifier extends Enemy

var shield_radius = 5.0
var attack_speed: Timer
var attack_cooldown: Timer
var all_enemies: Array
var can_attack: bool

signal resetting

func _init() -> void:
	super._init()
	vision_radius = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	# Create timer for attack speed
	attack_speed = Timer.new()
	attack_cooldown = Timer.new()
	attack_speed.set_one_shot(true)
	attack_cooldown.set_one_shot(true)
	add_child(attack_speed)
	add_child(attack_cooldown)
	attack_speed.wait_time = 3.0
	attack_speed.wait_time = 10.0
	attack_speed.connect('timeout', Callable(self, 'attack_reset'))

func _process(delta: float) -> void:
	if global_position.distance_to(navigation_agent.target_position) < attack_radius:
		if attack_cooldown.get_time_left() <= 0:
			can_attack = false
			attack()
	if attack_speed.get_time_left() > 0:
		for enemy in all_enemies:
			if 0 < abs(position.distance_to(enemy.position)) < shield_radius:
				enemy.apply_effect(EntityEffect.EffectID.INVINCIBLE)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	all_enemies = get_tree().get_nodes_in_group("Enemies")

func attack() -> void:
	super.attack()
	#play animation here
	attack_speed.start()
	#print("attack")
	$".".visible = true

func attack_reset():
	attack_speed.stop()
	resetting.emit()
	can_attack = true
	$".".visible = false
	$".".position.x = 0
	$".".position.z = 0
