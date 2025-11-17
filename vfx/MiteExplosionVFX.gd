@tool
extends AutoStartVFX

@export_category("Debugging")
@export_tool_button("Light Fuse") 
var light_fuse: 
	get: return func(): return start_fuse()

@export_category("Explosion Controls")
@export var explosion_radius : float
@export var explosion_color : Color
@export var smoke_color : Color
@export var fuse_delay : float = 1

@export_category("Pulse Controls")
@export var pulse_count : int = 3
@export var pulse_color : Color
@export var pulse_length_delay_ratio : float = 1
@export var pulse_material : Material
@export var pulse_timing : Curve
@export var pulse_energy : Curve

var pulse_material_original_albedo_color : Color
var pulse_material_original_emission_color : Color
var pulse_material_original_emission_energy : float
var pulse_timer : Timer
var pulse_delays : Array[float]
var current_pulse : int
var pulse_left : float
var pulse_length : float
var pulsing : bool

var fuse_lit : bool
var fuse_timer : Timer

signal exploded
signal pulsed

# Called when the node enters the scene tree for the first time.
func _ready():
	fuse_timer = $FuseTimer
	pulse_timer = $PulseTimer
	pulse_timer.timeout.connect(pulse)
	fuse_timer.timeout.connect(explode)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pulsing:
		pulse_left -= delta
		if pulse_left < 0:
			pulsing = false
			pulse_material.emission = pulse_material_original_emission_color
			pulse_material.albedo_color = pulse_material_original_albedo_color
			pulse_material.emission_enabled = false
			pulse_material.emission_energy_multiplier = pulse_material_original_emission_energy			
		else:
			var x = 1 - (pulse_left/pulse_length)
			x = -4 * (x-1) * (x)
			
			if pulse_energy:
				pulse_material.emission_energy_multiplier = pulse_energy.sample(1 - (pulse_left/pulse_length))
			else:
				pulse_material.emission_energy_multiplier = x * 3
			
			pulse_material.emission = pulse_material_original_emission_color.lerp(pulse_color, x)
			pulse_material.albedo_color = pulse_material_original_albedo_color.lerp(pulse_material_original_albedo_color * pulse_color, x)

func start_fuse():
	fuse_lit = true
	calculate_pulses()
	current_pulse = 0
	fuse_timer.start(fuse_delay)
	pulsing = true
	pulse_left = 0
	pulse_timer.start(pulse_delays[0])

func pulse():
	current_pulse += 1
	pulse_length = pulse_delays[current_pulse] * pulse_length_delay_ratio
	pulse_left = pulse_length
	pulse_material.emission_enabled = true
	if not pulsing:
		pulse_material_original_albedo_color = pulse_material.albedo_color
		pulse_material_original_emission_color = pulse_material.emission
		pulse_material_original_emission_energy = pulse_material.emission_energy_multiplier
	pulsing = true
	
	if current_pulse < pulse_count:
		pulse_timer.start(pulse_delays[current_pulse])
	pulsed.emit()
		

func calculate_pulses():
	pulse_delays.resize(pulse_count+1)
	if not pulse_timing:
		pulse_delays.fill(fuse_delay/(pulse_count+1))
	else:
		var delay_sum = 0
		var domain_size = pulse_timing.max_domain - pulse_timing.min_domain
		for i in range(pulse_count):
			var pulse_delay = pulse_timing.sample(i/(float(pulse_count)+1) * domain_size)
			delay_sum += pulse_delay
			pulse_delays[i] = (pulse_delay)
			
		pulse_delays[-1] = (pulse_timing.sample(pulse_timing.max_domain))
		delay_sum += pulse_delays[-1]
		
		for i in range(len(pulse_delays)):
			pulse_delays[i] *= fuse_delay/delay_sum
			
		var x = 0
		for num in pulse_delays:
			x += num
		
func explode():
	fuse_lit = false
	print("boom")
	exploded.emit()
	restart_particles()
