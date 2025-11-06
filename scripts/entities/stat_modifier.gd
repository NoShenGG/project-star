@abstract
class_name StatMod extends RefCounted

enum Stat {
	DMG,
	SPD,
	DEF
}

var value: int = 0
var type: Stat
var timer: SceneTreeTimer

@abstract func _init(_type: Stat, _value: int, _timer: SceneTreeTimer) -> void

func poll() -> float:
	return value

func end() -> void:
	timer = null

func finished() -> bool:
	if (timer.time_left == 0):
		timer = null
	return timer == null



@abstract
class DecayStat extends StatMod:
	var curr: float = 0
	var lifetime: float = 1
	
	func update(delta: float) -> float:
		curr -= value * delta / lifetime
		return curr
		
		
		
class Buff extends StatMod:
	func _init(_type: Stat, _value: int, _timer: SceneTreeTimer) -> void:
		value = _value
		type = _type
		timer = _timer
		
		
class Debuff extends StatMod:
	func _init(_type: Stat, _value: int, _timer: SceneTreeTimer) -> void:
		value = -_value
		type = _type
		timer = _timer
		
		
		
class DecayBuff extends Buff:
	func poll() -> float:
		return value * timer.time_left
		
		
class DecayDebuff extends Debuff:
	func poll() -> float:
		return value * timer.time_left
