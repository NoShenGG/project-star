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
	var colshape = $Hitboxes/Dash/CollisionShape3D as CollisionShape3D
	var old = colshape.shape as BoxShape3D
	var new = BoxShape3D.new()
	new.size = Vector3(old.size.x, old.size.y, special_dash_dist)
	colshape.shape = new
	$Hitboxes/Dash.position.z = special_dash_dist / 2
