extends CanvasLayer
class_name HUDLayer

@onready var game_manager : GameManager = $".."
@onready var main_hud_node : Control = $Control
@onready var point_counter : Label = %PointCounter

@onready var game_over_panel : PanelContainer = %GameOverPanel
@onready var game_over_score : Label = %GameOverScore
@onready var replay_button : Button = %ReplayButton

# Animations
var tween1 : Tween
const time1 := 0.2

# Loading / Start

func _ready():
	initial_state()

func initial_state() -> void:
	# Point counter
	point_counter.text = str(0)
	# Game over panel
	game_over_panel.hide()
	game_over_panel.pivot_offset_ratio = Vector2(0.5, 0.5)
	game_over_panel.scale = Vector2.ZERO

# Show / Hide animations

func show_anim() -> void:
	if tween1:
		tween1.kill()
	tween1 = create_tween()
	tween1.tween_property(game_over_panel,"visible", true, 0)
	tween1.tween_property(game_over_panel,"scale", Vector2(1,1), time1)
	tween1.parallel().tween_property(game_over_score,"text", str(game_manager.points), time1)
	tween1.tween_property(replay_button,"disabled", false, 0)

func hide_anim() -> void:
	if tween1:
		tween1.kill()
	tween1 = create_tween()
	tween1.set_parallel()
	tween1.tween_property(game_over_panel,"visible", false, time1)
	tween1.tween_property(game_over_panel,"scale", Vector2.ZERO, time1)

# Replay button

func _on_replay_button_pressed():
	replay_button.disabled = true
	hide_anim()
	game_manager.restart_game()

# Point counter

func update_point_coutner() -> void:
	point_counter.text = str(game_manager.points)

#
