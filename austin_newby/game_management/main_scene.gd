extends Node
class_name MainScene

"""
This node serves as the highest node in the tree.
(Its also the main scene loaded on startup)

All levels/menus are added as children of this node.
There is only ever one level loaded at once.
Loading is handled by loading_screen.gd and is called in GameManager.gd
"""

func _ready() -> void:
	GameManager.main_scene = self
	GameManager.load_level("Copied_Level1")
