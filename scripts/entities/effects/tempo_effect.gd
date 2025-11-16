class_name Tempo extends TimedEntityEffect

var dur: float
var spd: int
var dmg: int
var mesh: MeshInstance3D
var area: Area3D

func _init(duration: float, _mesh: MeshInstance3D, _area: Area3D, damage := 3, speed := 4) -> void:
	effect_duration = floor(duration * 1000)
	effect_tick_interval = effect_duration + 1
	dur = duration
	mesh = _mesh
	area = _area
	spd = speed
	dmg = damage
	id = EffectID.TEMPO;
	
func try_apply(entity: Entity) -> bool:
	if super(entity):
		entity.apply_buff(StatMod.DecayBuff.new(
			StatMod.Stat.SPD, spd, get_tree().create_timer(dur)))
		entity.apply_buff(StatMod.DecayBuff.new(
			StatMod.Stat.DMG, dmg, get_tree().create_timer(dur)))
		mesh.visible = true
		area.monitoring = true
		return true
	else:
		return false	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta: float) -> bool:
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
	
