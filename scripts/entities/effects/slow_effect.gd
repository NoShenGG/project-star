class_name SlowStatusEffect
extends TimedEntityEffect

var slow_factor: float
var active: bool = true
var original_speed: float = 0.0

func _init(_duration: float = 3.0, _slow_factor: float = 0.5) -> void:
	id = EffectID.SLOWED
	slow_factor = _slow_factor

	# convert duration to milliseconds since TimedEntityEffect uses ms
	effect_duration = int(_duration * 1000)
	effect_tick_interval = effect_duration  # no ticking, just one duration

func try_apply(entity: Entity) -> bool:
	# Let the base class handle setup and adding as a child
	if not super.try_apply(entity):
		return false

	# Store and modify movement speed
	original_speed = _entity._movement_speed
	_entity._movement_speed = original_speed * slow_factor

	# Connect to entity death to stop early if needed
	_entity.killed.connect(_on_entity_killed)

	return true

func _on_entity_killed() -> void:
	active = false

func process(delta: float) -> bool:
	# Use TimedEntityEffect’s built-in timing
	# Only continue if both time remains and entity is still active
	return super.process(delta) and active

func tick() -> void:
	# Could add visual indicator here (e.g., slow particles or effect)
	pass

func stop() -> void:
	# Clean up and restore speed
	if _entity:
		_entity._movement_speed = original_speed
		if _entity.killed.is_connected(_on_entity_killed):
			_entity.killed.disconnect(_on_entity_killed)

	active = false
