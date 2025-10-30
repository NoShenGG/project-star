class_name Tempo extends TimedEntityEffect

var dur: float
var spd: float
var dmg: float
var spd_added: float
var dmg_added: float
var mesh: MeshInstance3D
var area: Area3D

func _init(duration: float, _mesh: MeshInstance3D, _area: Area3D, damage := 5, speed := 10) -> void:
	effect_duration = floor(duration * 1000)
	effect_tick_interval = effect_duration + 1
	dur = duration
	mesh = _mesh
	area = _area
	spd = speed
	dmg = damage
	spd_added = speed
	dmg_added = damage
	id = EffectID.TEMPO;
	
func try_apply(entity: Entity) -> bool:
	if super(entity):
		entity._movement_speed += spd
		entity.damage_mult += dmg
		mesh.visible = true
		area.monitoring = true
		return true
	else:
		return false	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta: float) -> bool:
	var spd_diff = min(spd * delta / dur, spd_added)
	var dmg_diff = min(dmg * delta / dur, dmg_added)
	spd_added -= spd_diff
	dmg_added -= dmg_diff 
	_entity._movement_speed -= spd_diff
	_entity.damage_mult -= dmg_diff
	for body in area.get_overlapping_bodies():
		if body is Enemy:
			body.global_position -= \
				body.global_position.direction_to(_entity.global_position) \
				* 1.0 \
				* Vector3(1, 0, 1)
			(body as Enemy).try_damage(0.1)
	return super(delta)
	
func tick() -> void:
	pass

func stop() -> void:
	mesh.visible = false
	area.monitoring = false
	_entity._movement_speed -= spd_added
	_entity.damage_mult -= dmg_added
	spd_added = 0
	dmg_added = 0
	
