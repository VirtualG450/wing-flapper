extends CanvasLayer
class_name HUDLayer

@onready var game_manager : GameManager = $".."
@onready var main_hud_node : Control = $Control

@onready var score_section : MarginContainer = %ScoreSection
@onready var point_counter : Label = %PointCounter

@onready var record_section : HBoxContainer = %RecordSection
@onready var record_score_label : Label = %RecordScoreLabel

@onready var game_over_panel : PanelContainer = %GameOverPanel
@onready var game_over_score : Label = %GameOverScore

@onready var replay_button : Button = %ReplayButton
@onready var sound_button : Button = %SoundButton

var muted := false
# Animations
var tween1 : Tween
const time1 := 0.2

# Loading / Start

func _ready():
	initial_state()

func initial_state() -> void:
	# Point counter
	score_section.pivot_offset_ratio = Vector2(0.5, 0.5)
	point_counter.text = str(0)
	# Game over panel
	game_over_panel.hide()
	game_over_panel.pivot_offset_ratio = Vector2(0.5, 0.5)
	game_over_panel.scale = Vector2.ZERO

# Show / Hide animations

func show_anim() -> void:
	# Check if new record was made
	var new_record := false
	var new_points := game_manager.points
	if new_points > game_manager.record:
		new_record = true
		game_manager.record = new_points
		game_manager.save_record()
	game_over_score.text = "0"
	# Restart animation tweener
	if tween1:
		tween1.kill()
	tween1 = create_tween()
	tween1.set_parallel()
	tween1.tween_property(replay_button,"disabled", false, time1)
	# Hide point couter
	tween1.tween_property(score_section,"visible", false, time1)
	tween1.tween_property(score_section,"scale", Vector2.ZERO, time1)
	# Show game over panel
	tween1.tween_property(game_over_panel,"visible", true, 0)
	tween1.tween_property(game_over_panel,"scale", Vector2(1,1), time1)
	# Smooth value change for game over point counter and record when needed
	tween1.tween_method(_game_over_counter ,0, new_points, time1 + 1.0)
	if new_record:
		tween1.tween_method(_record_counter, 0, new_points, time1 + 1.0)

func hide_anim() -> void:
	if tween1:
		tween1.kill()
	tween1 = create_tween()
	tween1.set_parallel()
	# Hide game over panel
	tween1.tween_property(game_over_panel,"visible", false, time1)
	tween1.tween_property(game_over_panel,"scale", Vector2.ZERO, time1)
	# Show point coutner
	tween1.tween_property(score_section,"visible", true, 0)
	tween1.tween_property(score_section,"scale", Vector2(1,1), time1)

# Buttons

func _on_replay_button_pressed():
	replay_button.disabled = true
	hide_anim()
	game_manager.restart_game()

func _on_sound_button_pressed():
	sound_button.button_pressed = false
	muted = !muted
	if muted:
		sound_button.icon.region.position.x = 32
		AudioServer.set_bus_mute(0,true)
	else:
		sound_button.icon.region.position.x = 0
		AudioServer.set_bus_mute(0,false)

# Point counter

func update_point_counter() -> void:
	point_counter.text = str(game_manager.points)

func _game_over_counter(new_value:int) -> void:
	game_over_score.text = str(new_value)

func _record_counter(new_value:int) -> void:
	record_score_label.text = str(new_value)
