## An [EntityEffect] that ticks over time and removes itself when done.
##
## Set [member effect_tick_interval] > [member effect_duration] to never tick
## the effect. All times are in msec unless listed otherwise.
@abstract
class_name TimedEntityEffect extends EntityEffect

var effect_duration: int
var effect_tick_interval: int
var _last_tick: int
var _current_time: int

func try_apply(entity: Entity) -> bool:
	_current_time = 0
	_last_tick = 0
	return super(entity)

func process(delta: float) -> bool:
	_current_time += floori(delta * 1000)
	var valid_time: int = maxi(_current_time, effect_duration)
	var time_since_last_tick: int = valid_time - _last_tick
	if time_since_last_tick >= effect_tick_interval:
		var ticks: int = time_since_last_tick / effect_tick_interval
		for i in range(ticks):
			tick()
		_last_tick += effect_tick_interval * ticks
	if _current_time >= effect_duration:
		return false
	return true

@abstract
func tick() -> void
