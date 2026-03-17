extends Node2D
class_name GameManager

@onready var bird_node : Bird = $Bird
@onready var hud_node : HUDLayer = $HUD

var points := 0

# Wait for initial press to enable the bird, only at game start.
func _unhandled_input(event):
	if event.is_action("bird_jump"):
		set_process_unhandled_input(false)
		bird_node.enable_bird()
		hud_node.hide_anim()

## Show game over mini menu
func game_over() -> void:
	hud_node.show_anim()

## Restarts bird and points
func restart_game() -> void:
	points = 0
	bird_node.restart_bird()
	bird_node.enable_bird()
