class_name Fortifier extends Enemy

var shield_radius = 5.0
var attack_speed: Timer
var all_enemies: Array

signal resetting

func _init() -> void:
	super._init()
	vision_radius = 2
	# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	super._ready()
	# Create timer for attack speed
	attack_speed = Timer.new()
	add_child(attack_speed)
	attack_speed.wait_time = 3.0
	attack_speed.connect('timeout', Callable(self, 'attack_reset'))

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	all_enemies = get_tree().get_nodes_in_group("Enemies")

func attack() -> void:
	super.attack()
	#play animation here
	attack_speed.start()
	#print("attack")
	while not attack_speed.is_stopped():
		for enemy in all_enemies:
			if 0 < abs(position.distance_to(enemy.position)) < shield_radius:
				enemy.apply_effect(EntityEffect.EffectID.INVINCIBLE)
		$".".visible = true

func attack_reset():
	attack_speed.stop()
	resetting.emit()
	$".".visible = false
	$".".position.x = 0
	$".".position.z = 0
