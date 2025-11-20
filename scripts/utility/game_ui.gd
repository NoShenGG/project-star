extends Control

@onready var nova = $MarginContainer/Offset/Nova
@onready var rene = $MarginContainer/Offset/Rene
@onready var dawn = $MarginContainer/Offset/Dawn

@export var ANIM_TIME: float = 0.2
@export var SWITCH_ANIMATION_EASE_CURVE: Curve # Should be a 0 to 1 easing curve.

@onready var player_manager: PlayerManager = owner as PlayerManager

class PortraitLocation:
	var position: Vector2
	var scale: Vector2
	
	func _init(position: Vector2, scale: Vector2):
		self.position = position
		self.scale = scale

var player_ui_nodes: Dictionary[String, GameUiPortrait]
var portrait_locations: Array[PortraitLocation]

var character_queue: Array[String]
var old_locations: Dictionary[String, PortraitLocation]
var animation_progress: float


func _ready() -> void:
	player_ui_nodes = {
		player_manager.NOVA: nova,
		player_manager.RENE: rene,
		player_manager.DAWN: dawn,
	}
	
	# NOTE: the index of the portrait array goes from bottom to top, i.e. portrait 0 is the main 
	# portrait. In the scene, the UI is laid out [Nova, Rene, Dawn]. As such, we will initialize 
	# portrait location 0 with Nova's position and scale, potrait location 1 with Rene's, etc.
	portrait_locations = [
		PortraitLocation.new(nova.position, nova.scale),
		PortraitLocation.new(rene.position, rene.scale),
		PortraitLocation.new(dawn.position, dawn.scale),
	]
	
	character_queue = [player_manager.NOVA, player_manager.RENE, player_manager.DAWN]
	old_locations = {}
	capture_locations()
	animation_progress = 0

func capture_locations():
	for p in character_queue:
		old_locations[p] = PortraitLocation.new(player_ui_nodes[p].position, player_ui_nodes[p].scale)
	
func get_ind(player: String) -> int:
	for i in character_queue.size():
		if player == character_queue[i]:
			return i
	return -1
	
func _process(delta: float) -> void:
	if animation_progress < 1:
		animation_progress += delta/ANIM_TIME
	
	for player in player_ui_nodes:
		var new_ind = get_ind(player)
		
		var old = old_locations[player]
		var new = portrait_locations[new_ind]
		player_ui_nodes[player].position = old.position + \
			SWITCH_ANIMATION_EASE_CURVE.sample(clamp(animation_progress, 0, 1)) * (new.position - old.position)
		player_ui_nodes[player].scale = old.scale + \
			SWITCH_ANIMATION_EASE_CURVE.sample(clamp(animation_progress, 0, 1)) * (new.scale - old.scale)

func on_player_health_update(player: Player, percent: float) -> void:
	(player_ui_nodes[player.name] as GameUiPortrait).update_health(percent)
	
func on_player_sp_update(player: Player, percent: float) -> void:
	(player_ui_nodes[player.name] as GameUiPortrait).update_special(percent)

func on_player_switch(player: Player) -> void:
	var new_queue: Array[String] = [player.name]
	for p in character_queue:
		if p == player.name:
			continue
		new_queue.append(p)
	character_queue = new_queue
	
	capture_locations()
	animation_progress = 0
			
