class_name Rene extends Player

@export_category("Rene Special")
@export var release_pause: float = 0.5
@export var special_dash_dist: float = 10



'''
This class mostly holds configuration for Rene.
It may eventually hold some signal binding or wtv.
'''

func _ready() -> void:
	super()
	$ForwardRay.target_position = Vector3.FORWARD * max(special_dash_dist, dash_distance)
    # Not implemented yet
	_has_special = false

# Override these functions to prevent special attack functionality
func use_special() -> void:
	pass

func set_special_cd() -> void:
	pass
