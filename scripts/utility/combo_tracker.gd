extends Node

#clicking time window
const reset_Timer: float = 0.75
#tracks what combo character is on
var combo_count: int = 0
#declares a timer
var timer: Timer
@onready var combo_label: Label = $"CanvasLayer/ComboLabel"
#detects the basic atk for a combo,adds to combo, and resets timer
func _input(event) -> void:
	if event.is_action_pressed("basic_attack"):
		if timer.time_left  <= 0.0:
			combo_count = 0
		combo_count += 1
		combo_label_updater()
		timer.start(reset_Timer)
#setups up the oneshot timer
func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(Callable(self, "timer_timedout"))
	combo_label_updater()
	
#resets the combo
func timer_timedout() -> void:
	combo_count = 0
	combo_label_updater()
	
#updates the combo
func combo_label_updater() -> void:
	combo_label.text = "Combo x%d" % combo_count
	combo_label.visible = combo_count > 0
