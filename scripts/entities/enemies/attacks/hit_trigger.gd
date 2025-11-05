extends Node

@onready var main: GPUParticles3D = $main
@onready var sparks: GPUParticles3D = $sparks


var enabled: bool = false
var timeElapsed: float = 0
@export var timeLimit: float = 0.5

func _ready():
	main.emitting = true
	print("started the hit!")
	
func _physics_process(delta):
	timeElapsed += delta
	if (!enabled && timeElapsed >= timeLimit):
		print("started the sparks!")
		sparks.emitting = true
		enabled = true
