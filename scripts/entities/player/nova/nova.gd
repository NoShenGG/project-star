class_name Nova extends Player

@export_category("Nova Special")
@export var release_pause: float = 0.5
@export var special_dash_dist: float = 10



'''
This class mostly holds configuration for Nova.
It may eventually hold some signal binding or wtv.
'''

func _ready() -> void:
	super()
	$ForwardRay.target_position = Vector3.FORWARD * max(special_dash_dist, dash_distance)
