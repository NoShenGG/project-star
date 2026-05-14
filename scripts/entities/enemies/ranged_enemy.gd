class_name RangedEnemy extends Enemy

@export var projectile_scene: PackedScene

var target_desired_distance = attack_radius

func _ready():
	navigation_agent.target_desired_distance = target_desired_distance
	super()

#func _physics_process(_delta: float) -> void:
#	super(_delta)
