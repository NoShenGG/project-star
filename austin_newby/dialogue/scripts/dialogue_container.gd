extends Menu

const dialogue_scene = preload("uid://df2acff0x2cqk")
var active_json : Dictionary # prevents repeatedly loading a json
var previous_file_path : String # determine if requested json has changed
var current_scene_key : String

signal main_dialogue_called
signal main_dialogue_sfx(image : Texture2D)
signal sub_dialogue_called
signal sub_dialogue_sfx(image : Texture2D)

signal dialogue_finished

func _enter_tree() -> void:
	hide()

func read(dialogue_array:Array[DialogueResource]):
	kill_dialogue()
	await get_tree().create_timer(0.01).timeout # allows time for dialogues to be freed
	#get_tree().create_tween().tween_property(self, "modulate", Color.WHITE, 0.1)
	instantiate_dialogue(dialogue_array)

# Instantiates new dialogue scene with message_array
func instantiate_dialogue(dialogue_array:Array[DialogueResource]):
	if (GameMenu.game_menu): GameMenu.game_menu.add_menu(self)
	await get_tree().create_timer(0.5).timeout
	if (!self): return
	var d = dialogue_scene.instantiate()
	d.speaker_image = %SpeakerImage
	d.name_label = %NameLabel
	d.dialogue_array = dialogue_array
	d.dialogue_container = self
	d.nine_patch_text_rect = %TextRect
	%UIDialogueBox.add_child(d)
	
	d.main_dialogue_called.connect(main_dialogue_recieved)
	d.main_dialogue_sfx.connect(main_dialogue_image_recieved)
	d.sub_dialogue_called.connect(sub_dialogue_recieved)
	d.sub_dialogue_sfx.connect(sub_dialogue_image_recieved)
	
	await open()
	
	await d.dialogue_finished
	await close()
	dialogue_finished.emit()
	if (GameMenu.game_menu): GameMenu.game_menu.remove_menu(self)

func main_dialogue_recieved():
	main_dialogue_called.emit()
func main_dialogue_image_recieved(image : Texture2D):
	main_dialogue_sfx.emit(image)
func sub_dialogue_recieved():
	sub_dialogue_called.emit()
func sub_dialogue_image_recieved(image : Texture2D):
	sub_dialogue_sfx.emit(image)

# Destroys any children of DialogueBox
func kill_dialogue():
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
	#super()
	hide()
	modulate = Color.TRANSPARENT
	z_index = 1
	
	var magnitude = scale.x if scale.x > scale.y else scale.y
	scale_magnitude = magnitude
