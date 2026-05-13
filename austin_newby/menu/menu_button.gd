extends Button
class_name AnimatedButton

var menu : Menu

var tween : Tween

func _ready() -> void:
	menu = find_menu()
	
	assert(menu != null, name + " is a MenuElement without a menu! please ensure its a part of the heirarchy of a Menu and not a child")
	
	menu.menu_shown.connect(opened)
	menu.menu_closed.connect(closed)
	menu.menu_hidden.connect(func(): hide())
	
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	focus_entered.connect(_on_focus_enter)
	focus_exited.connect(_on_focus_exit)
	mouse_entered.connect(_on_focus_enter)
	mouse_exited.connect(_on_focus_exit)
	
	offset_transform_enabled = true

var menu_just_opened : bool

func find_menu(node : Node = self) -> Menu:
	if (node.get_parent() == null): return null
	
	if (node.get_parent() is Menu):
		return node.get_parent() as Menu
	else:
		return find_menu(node.get_parent())

func opened() -> void:
	if (tween): tween.kill()
	offset_transform_scale = Vector2(1,0)
	
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "offset_transform_scale", Vector2.ONE, 0.4)
	menu_just_opened = true
	await get_tree().process_frame
	menu_just_opened = false
func closed() -> void:
	if (tween): tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "offset_transform_scale", Vector2.DOWN, 0.2)
func _on_button_down():
	if (!menu.is_open): return
	if (tween): tween.kill()
	
	offset_transform_scale = Vector2(0.83,0.6)
	if (%"Button Press SFX"):
		%"Button Press SFX".play(true)
		print("play")
func _on_button_up(): 
	if (!menu.is_open): return
	if (tween): tween.kill()
	print('button up')
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "offset_transform_scale", Vector2.ONE, 0.25)



func _on_focus_enter():
	if menu.transitioning:
		await menu.menu_transition_finished
		if !has_focus() and !is_hovered(): return
	if (!menu.is_open): return
	if (tween): tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "offset_transform_scale", Vector2(1.15,1.31), 0.1)
	if (%"Button Hover SFX" and !menu_just_opened):
		%"Button Hover SFX".play(true)
		print("play")
func _on_focus_exit():
	if (!menu.is_open or menu.transitioning): return
	if (tween): tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "offset_transform_scale", Vector2.ONE, 0.25)
