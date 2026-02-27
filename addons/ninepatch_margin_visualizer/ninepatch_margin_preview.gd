@tool
extends Control

class_name NinePatchMarginVisualizerPreview

# EditorSettings keys for persistence
const SETTINGS_PREFIX: String = "ninepatch_margin_visualizer/"
const SETTING_SHOW_STRETCH: String = SETTINGS_PREFIX + "show_stretch_regions"
const SETTING_EXPANDED_VIEW: String = SETTINGS_PREFIX + "expanded_view"

# Reference to the NinePatchRect node that this preview overlays
var target: NinePatchRect

# UI state toggles (loaded from EditorSettings)
var show_stretch_regions_overlay: bool = false
var expanded_view: bool = true

# State tracking for optimization
var _previous_hash: int = 0

# Cached sizes
const COLLAPSED_SIZE: Vector2 = Vector2(200, 200)
const EXPANDED_SIZE: Vector2 = Vector2(400, 400)


func _ready() -> void:
	# Ensure drawing does not bleed into other inspector properties
	clip_contents = true

	var editor_settings: EditorSettings = _load_settings()
	_setup_ui(editor_settings)


func _load_settings() -> EditorSettings:
	var editor_settings: EditorSettings = EditorInterface.get_editor_settings()

	# Ensure EditorSettings defaults exist
	if not editor_settings.has_setting(SETTING_SHOW_STRETCH):
		editor_settings.set_setting(SETTING_SHOW_STRETCH, false)
	if not editor_settings.has_setting(SETTING_EXPANDED_VIEW):
		editor_settings.set_setting(SETTING_EXPANDED_VIEW, true)

	# Load persisted state
	show_stretch_regions_overlay = editor_settings.get_setting(SETTING_SHOW_STRETCH)
	expanded_view = editor_settings.get_setting(SETTING_EXPANDED_VIEW)

	# Apply initial size
	custom_minimum_size = EXPANDED_SIZE if expanded_view else COLLAPSED_SIZE

	return editor_settings


func _setup_ui(editor_settings: EditorSettings) -> void:
	# Create a background panel for contrast on busy textures
	var panel: PanelContainer = PanelContainer.new()
	panel.position = Vector2(4, 4)

	# Create a vertical layout for toggles
	var toolbar: VBoxContainer = VBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 4)
	panel.add_child(toolbar)

	# Stretch region toggle
	var overlay_toggle: CheckBox = _create_checkbox("Show Stretch Regions", show_stretch_regions_overlay)
	overlay_toggle.toggled.connect(
		func(value: bool) -> void:
			show_stretch_regions_overlay = value
			editor_settings.set_setting(SETTING_SHOW_STRETCH, value)
			queue_redraw()
	)

	# Expanded view toggle
	var expand_toggle: CheckBox = _create_checkbox("Expanded View", expanded_view)
	expand_toggle.toggled.connect(
		func(value: bool) -> void:
			expanded_view = value
			editor_settings.set_setting(SETTING_EXPANDED_VIEW, value)
			custom_minimum_size = EXPANDED_SIZE if expanded_view else COLLAPSED_SIZE
			queue_redraw()
	)

	toolbar.add_child(overlay_toggle)
	toolbar.add_child(expand_toggle)
	add_child(panel)


func _create_checkbox(text: String, pressed: bool) -> CheckBox:
	var checkbox: CheckBox = CheckBox.new()
	checkbox.text = text
	checkbox.button_pressed = pressed
	return checkbox


func _process(delta_time: float) -> void:
	if not is_instance_valid(target) or not target.texture:
		return

	# Create a hash of the current state that affects visuals.
	var current_hash: int = hash(
		[
			target.patch_margin_left,
			target.patch_margin_right,
			target.patch_margin_top,
			target.patch_margin_bottom,
			target.texture.get_path(),
			size,
			# Hash the theme color so it updates immediately if the user changes themes
			get_theme_color("accent_color", "Editor"),
		],
	)

	if current_hash != _previous_hash:
		_previous_hash = current_hash
		queue_redraw()


func _draw() -> void:
	if not is_instance_valid(target) or not target.texture:
		return

	var texture_size: Vector2 = target.texture.get_size()
	if texture_size.x == 0 or texture_size.y == 0:
		return

	var rectangle: Rect2 = Rect2(Vector2.ZERO, size)
	var geometry: Dictionary = _calculate_draw_geometry(rectangle, texture_size)

	_draw_texture(geometry.drawn_rectangle)
	_draw_grid(rectangle, geometry)

	if show_stretch_regions_overlay:
		var center_rect: Rect2 = Rect2(
			Vector2(geometry.left, geometry.top),
			Vector2(geometry.right - geometry.left, geometry.bottom - geometry.top),
		)
		_draw_stretch_regions(
			geometry.drawn_rectangle,
			center_rect,
			geometry.left,
			geometry.right,
			geometry.top,
			geometry.bottom,
		)


func _calculate_draw_geometry(rectangle: Rect2, texture_size: Vector2) -> Dictionary:
	var scale_factor: float = min(
		rectangle.size.x / texture_size.x,
		rectangle.size.y / texture_size.y,
	)

	var drawn_size: Vector2 = texture_size * scale_factor
	var drawn_position: Vector2 = (rectangle.size - drawn_size) * 0.5
	var drawn_rectangle: Rect2 = Rect2(drawn_position, drawn_size)

	var scale_vec: Vector2 = Vector2.ONE * scale_factor

	var left: float = drawn_rectangle.position.x + target.patch_margin_left * scale_vec.x
	var right: float = drawn_rectangle.end.x - target.patch_margin_right * scale_vec.x
	var top: float = drawn_rectangle.position.y + target.patch_margin_top * scale_vec.y
	var bottom: float = drawn_rectangle.end.y - target.patch_margin_bottom * scale_vec.y

	return {
		"drawn_rectangle": drawn_rectangle,
		"left": left,
		"right": right,
		"top": top,
		"bottom": bottom,
	}


func _draw_texture(drawn_rectangle: Rect2) -> void:
	draw_texture_rect(target.texture, drawn_rectangle, false)


func _draw_grid(rectangle: Rect2, geometry: Dictionary) -> void:
	# Retrieve the dynamic accent color from the Editor theme
	var line_color: Color = get_theme_color("accent_color", "Editor")
	# Ensure the alpha is high enough to be visible over textures
	line_color.a = 0.9
	var line_width: float = 2.0

	var left: float = geometry.left
	var right: float = geometry.right
	var top: float = geometry.top
	var bottom: float = geometry.bottom

	draw_line(Vector2(left, 0), Vector2(left, rectangle.size.y), line_color, line_width)
	draw_line(Vector2(right, 0), Vector2(right, rectangle.size.y), line_color, line_width)
	draw_line(Vector2(0, top), Vector2(rectangle.size.x, top), line_color, line_width)
	draw_line(Vector2(0, bottom), Vector2(rectangle.size.x, bottom), line_color, line_width)


func _draw_hatched_rect(rectangle: Rect2, color: Color) -> void:
	if rectangle.size.x <= 0 or rectangle.size.y <= 0:
		return

	var spacing: float = 6.0
	draw_rect(rectangle, Color(color.r, color.g, color.b, 0.1), true)

	var lines: PackedVector2Array = PackedVector2Array()

	var x_position: float = rectangle.position.x - rectangle.size.y

	while x_position < rectangle.end.x:
		var start_point: Vector2 = Vector2(x_position, rectangle.end.y)
		var end_point: Vector2 = Vector2(x_position + rectangle.size.y, rectangle.position.y)

		lines.append(start_point)
		lines.append(end_point)

		x_position += spacing

	if not lines.is_empty():
		draw_multiline(lines, color, 1.0)


func _draw_stretch_regions(
		drawn_rectangle: Rect2,
		center_rectangle: Rect2,
		left: float,
		right: float,
		top: float,
		bottom: float,
) -> void:
	_draw_hatched_rect(center_rectangle, Color(0.2, 0.6, 1.0, 0.4))

	_draw_hatched_rect(
		Rect2(left, drawn_rectangle.position.y, right - left, top - drawn_rectangle.position.y),
		Color(0.2, 1.0, 0.4, 0.35),
	)

	_draw_hatched_rect(
		Rect2(left, bottom, right - left, drawn_rectangle.end.y - bottom),
		Color(0.2, 1.0, 0.4, 0.35),
	)

	_draw_hatched_rect(
		Rect2(drawn_rectangle.position.x, top, left - drawn_rectangle.position.x, bottom - top),
		Color(1.0, 0.8, 0.2, 0.35),
	)

	_draw_hatched_rect(
		Rect2(right, top, drawn_rectangle.end.x - right, bottom - top),
		Color(1.0, 0.8, 0.2, 0.35),
	)
