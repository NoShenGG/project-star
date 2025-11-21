extends Node

func _ready() -> void:
	owner.main_dialogue_sfx.connect(new_audio)
	owner.sub_dialogue_sfx.connect(new_audio)

func new_audio(image : Texture2D):
	print("audio playing")
	if (image and image.resource_path.to_lower().contains("nova")):
		$Nova.play()
		print("audio playing 1")
	elif (image and image.resource_path.to_lower().contains("rene")):
		$Rene.play()
		print("audio playing 2")
	elif (image and image.resource_path.to_lower().contains("dawn")):
		$Dawn.play()
		print("audio playing 3")
	else:
		$Generic.play()
		print("audio playing 4")
