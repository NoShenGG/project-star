extends MarginContainer
class_name DialogueContainer

const dialogue_scene = preload("uid://df2acff0x2cqk")
var active_json : Dictionary # prevents repeatedly loading a json
var previous_file_path : String # determine if requested json has changed
var current_scene_key : String

func read(filePath:String, scene_key:String):
	kill_dialogue()
	current_scene_key = scene_key
	await get_tree().create_timer(0.01).timeout # allows time for dialogues to be freed
	#get_tree().create_tween().tween_property(self, "modulate", Color.WHITE, 0.1)
	if filePath == previous_file_path:
		instantiate_dialogue(active_json[scene_key])
	else:
		active_json = load_json(filePath)
		instantiate_dialogue(active_json[scene_key])
	previous_file_path = filePath

# Instantiates new dialogue scene with message_array
func instantiate_dialogue(message_array: Array):
	var d = dialogue_scene.instantiate()
	d.speaker_image = %SpeakerImage
	d.name_label = %NameLabel
	d.messages = message_array
	d.dialogue_container = self
	d.nine_patch_text_rect = %TextRect
	%UIDialogueBox.add_child(d)

# Destroys any children of DialogueBox
func kill_dialogue():
	print("KILING")
	if %UIDialogueBox.get_child_count() > 0:
		for n in %UIDialogueBox.get_children():
			n.queue_free()

# Returns parsed result of json
func load_json(filePath : String):
	print_rich("[color=gray]*** loading %s as json..." % filePath)
	if FileAccess.file_exists(filePath):
		var json = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(json.get_as_text())
		if parsedResult is Dictionary: 
			print_rich("[color=gray]*** json loaded!")
			return parsedResult
		else:
			push_error("Error reading file %s" % filePath)
	else:
		push_error("File %s doesn't exist!" % filePath)
		
func update_talk_sprite(image : Texture2D):
	%SpeakerImage.texture = image

func _ready():
	modulate = Color.TRANSPARENT
