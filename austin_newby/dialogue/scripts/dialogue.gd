extends Control
class_name Dialogue

const IMG_PATH = "res://austin_newby/dialogue/resources/"

@onready var next_char = $next_char #timer for typewriter effect
@onready var next_message = $next_message
@onready var label = %TextLabel #main dialogue label
@onready var small_label = %SmallTextLabel #teeny tiny label
@onready var small_speaker_image: TextureRect = %SmallSpeakerImage

#These are assigned by the container during initialization
var speaker_image : TextureRect
var name_label : RichTextLabel
var dialogue_container : DialogueContainer
var messages ={} #dictionary, look at json

var current_message = 0 #index of message
var current_char = 0 #index of char
var typing_speed := 0.033 #speed of typewriter
var display = ""

#Input things
var skip_held : bool #SHIFT, skips typewriter effect
var super_skip_held : bool #C, skips text nearly instantly

signal text_interact()

func _ready():
	dialogue_container.modulate = Color.TRANSPARENT
	get_tree().create_tween().tween_property(dialogue_container, "modulate", Color.WHITE, 1)
	label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING # prevents typewriter messing up line-wrapping
	display += messages[current_message]["line"]
	display += ' ' # +space = proper punctuation detection
	label.text = display
	label.set_visible_characters(0)
	%SmallTextLabel.text = ""
	if messages[current_message]["small_img"] == "": %SmallSpeakerImage.texture = null
	else: %SmallSpeakerImage.texture = load(IMG_PATH + "/" + messages[current_message]["small_img"])
	name_label.text = "~ %s ~" % messages[current_message]["char"]
	speaker_image.texture = load(IMG_PATH + "/" + messages[current_message]["img"])
	
	# Check if skip is held down prior to dialogue opening
	if Input.is_action_pressed("text_skip"):
		skip_held = true
	if Input.is_action_pressed("text_super_skip"):
		super_skip_held = true
	start_dialogue()

func start_dialogue():
	next_char.start(typing_speed)

func stop_dialogue():
	print_rich("[color=turquoise]Dialogue complete.")
	get_tree().create_tween().tween_property(dialogue_container, "modulate", Color.TRANSPARENT, 0.2)
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
		%SmallTextLabel.text = messages[current_message]["small_line"]
		%SmallTextSpeakerSeperator.modulate = Color.TRANSPARENT
		var tween = get_tree().create_tween()
		tween.tween_property(%SmallTextSpeakerSeperator, "modulate", Color.WHITE, 0.3)
		if messages[current_message]["small_img"] == "": %SmallSpeakerImage.texture = null
		else: %SmallSpeakerImage.texture = load(IMG_PATH + "/" + messages[current_message]["small_img"])
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
		display += messages[current_message]["line"]
		%SmallTextLabel.text = ""
		name_label.text = "~ %s ~" % messages[current_message]["char"]
		display += ' '
		label.text = display
		label.visible_characters = 0
		speaker_image.texture = load(IMG_PATH + "/" + messages[current_message]["img"])
		current_char = 0
		%SmallTextSpeakerSeperator.modulate = Color.TRANSPARENT
		next_char.start()
