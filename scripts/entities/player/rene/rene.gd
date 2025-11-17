class_name Rene extends Player

signal update_counters(num: int)

@export var ui_counters: Array[UIConsumable]


var counters: int:
	set(val):
		val = clampi(val, 0, 4)
		update_counters.emit(val)
		counters = val
		for i in range(counters):
			ui_counters[i].appear()
		for i in range(4 - counters):
			ui_counters[counters + i].disappear()

'''
This class mostly holds configuration for Rene.
It may eventually hold some signal binding or wtv.
'''

func _ready() -> void:
	super()
	_has_special = false

# Override these functions to prevent special attack functionality
func use_special() -> void:
	pass

func set_special_cd() -> void:
	pass
