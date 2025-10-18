extends Control
class_name Dialogue

@onready var next_char = $next_char
@onready var next_message = $next_message
@onready var label = %TextLabel
@onready var small_label = %SmallTextLabel
@onready var small_speaker_image: TextureRect = %SmallSpeakerImage

var messages =[
	"default1",
	"default2"
]

var typing_speed := 0.033
var time_btwn_message := 2 # used for auto advance

var current_char = 0 #index of character within a message
var current_message = 0 #index of message
var display = "" #what to display in a label

var skip_held : bool
var super_skip_held : bool

var dialogue_container

signal text_interact()

func _ready():
	label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING # This prevents the typing messing up line-wrapping
	start_dialogue()
	display += messages[current_message]
	display += ' ' # adds a space at the end for proper punctuation detection
	label.text = display
	label.set_visible_characters(0)
	
	# Check if skip is held down prior to dialogue opening
	if Input.is_action_pressed("text_skip"):
		skip_held = true
	if Input.is_action_pressed("text_super_skip"):
		super_skip_held = true

func start_dialogue():
	next_char.start(typing_speed)

func stop_dialogue():
	print_rich("[color=turquoise]Dialogue complete.")
	#get_tree().create_tween().tween_property(dialogue_container, "modulate", Color(0,0,0,0), 0.1)
	queue_free()

# Connect this to the project's Input Map
func _unhandled_key_input(event: InputEvent) -> void:
	# Emits signal to advance dialogue
	if event.is_action_pressed("text_interact"): # Z
		text_interact.emit()
		
	# Assign values to skip based on held key
	if event.is_action("text_skip"):
		skip_held = true
	if event.is_action_released("text_skip"):
		skip_held = false
	if event.is_action_pressed("text_super_skip"):
		super_skip_held = true
		_on_next_char_timeout()
	if event.is_action_released("text_super_skip"):
		super_skip_held = false

func _on_next_char_timeout():
	# Timer automatically restarts  at 0
	if super_skip_held:
		label.visible_characters = len(display)
		current_char = len(display)
		next_char.stop()
		next_message.one_shot = true
		next_message.start(0.05)
	elif current_char < len(display):
		# instantly completes text if skip (shift) is held
		if skip_held:
			label.visible_characters = len(display)
			current_char = len(display)
		# skips writing tags contained with [], allows BBCode
		elif display[current_char] == '[':
			for n in range(current_char, display.findn(']', current_char) + 1): #+1 so include last ]
				current_char += 1
		# writes text as normal
		else:
			label.visible_characters += 1
			current_char += 1
	else:
		next_char.stop()
		await text_interact
		next_message.one_shot = true
		next_message.start(0.01)


func _on_next_message_timeout():
	if current_message == len(messages) - 1: #length starts at 1, index starts at 0
		stop_dialogue()
	else:
		#Reset everything
		current_message += 1
		display = ""
		display += messages[current_message]
		display += ' '
		label.text = display
		label.visible_characters = 0
		current_char = 0
		next_char.start()
