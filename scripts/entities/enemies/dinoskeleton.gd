class_name DinoSkeleton extends Enemy

signal chase
signal spit_commit
signal fire_prepare
signal fire_commit

@export var spit_source_node: Node3D
@export var spit_distance = 8.0
@export var spit_projectile_scene: PackedScene
@onready var spit_cd: Timer = $SpitCooldown

@export var fire_distance = 4.0
@export var fire_anticipation_scene: PackedScene
@export var fire_effect_scene: PackedScene
@onready var fire_cd: Timer = $FireCooldown

@export var target_node: Node3D
@onready var player_ref = GameManager.curr_player

func _ready():
	target_node = null;
	navigation_agent.target_desired_distance = spit_distance
	super()

#func _physics_process(_delta: float) -> void:
#	super(_delta)
