extends HapticHandler
class_name DesktopHapticHandler

var current_vibration : float

func haptic(frequency: float, amplitude: float, duration_sec: float, delay_sec: float):
	if ((!frequency and !amplitude) or !duration_sec): return
	if (delay_sec > 0): await get_tree().create_timer(delay_sec).timeout
	
	if (current_vibration > amplitude): 
		print("returning   " + str(Input.get_joy_vibration_strength(0).y))
		return
	Input.start_joy_vibration(0, frequency, amplitude, duration_sec)
	current_vibration = amplitude
	await get_tree().create_timer(duration_sec).timeout
	if (current_vibration == amplitude):
		current_vibration = 0
