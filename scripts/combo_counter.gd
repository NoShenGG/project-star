extends Control

@onready var text: Label = $Text
@onready var fire: AnimatedSprite2D = $Fire
@onready var timer: Timer = $Timer
## the magnitude of the scale at a time
@export var bounce_size : Curve = Curve.new()
## how long the bounce animation will last
@export var lifetime : float = 0.2
var tween: Tween
var bounce_count : int
var og_scale : Vector2
var fire_og_scale: Vector2

var combo: int = 0

func _ready() -> void:
	og_scale = text.scale
	fire.play()
	fire_og_scale = fire.scale
	combo_reset()
	timer.timeout.connect(combo_reset)
	

func _process(_delta: float) -> void:
	text.text = "x%02d" % combo

func combo_inc():
	combo += 1
	bounce_count += 1
	if bounce_count == 1:
		tween_bounce()
	fire.scale = fire_og_scale * min(floor(combo/10)/5.0, 1)
	timer.start()
	
func combo_reset():
	combo += 0
	fire.scale = fire_og_scale

func tween_bounce() -> void:
	if tween != null: # If tween doesnt exist, its the init call
		bounce_count -= 1
	if bounce_count > 0: # If has bounces left, start next
		print("here")
		tween = get_tree().create_tween()
		tween.tween_method(func(step): text.scale = og_scale * bounce_size.sample(step),
				 0.0, 1.0, lifetime)
		tween.tween_callback(tween_bounce)
	else: # else clear tween
		tween = null
