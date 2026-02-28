class_name InputIconSwapper extends TextureRect

@export var icons : Array[InputIconInfo]

@export var input_name : String = "text_interact"

var cur_icon_info : InputIconInfo

func _enter_tree() -> void:
	GameManager.new_input_type.connect(update_icons)
	update_icons()

func update_icons():
	for icon in icons:
		if icon.input_type == GameManager.current_input_type:
			cur_icon_info = icon
			texture = cur_icon_info.unpressed_icon
			return
	
	## if the input type is a controller and we dont have what it wants, we want to use generic controller as a backup
	if (GameManager.current_input_type != GameManager.InputType.KEYBOARD):
		for icon in icons:
			if icon.input_type == GameManager.InputType.GENERIC_CONTROLLER:
				cur_icon_info = icon
				texture = cur_icon_info.unpressed_icon
				return

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(input_name):
		pressed_icon()
	elif event.is_action_released(input_name):
		unpressed_icon()

func pressed_icon():
	if (cur_icon_info and cur_icon_info.pressed_icon):
		texture = cur_icon_info.pressed_icon
func unpressed_icon():
	if (cur_icon_info and cur_icon_info.unpressed_icon):
		texture = cur_icon_info.unpressed_icon
