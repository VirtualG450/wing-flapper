extends Node2D
class_name GameManager
# Other nodes
@onready var bird_node : Bird = $Bird
@onready var hud_node : HUDLayer = $HUD
@onready var wall_manager : WallManager = $WallManager
# Sound players
@onready var point_scored_player : AudioStreamPlayer = $PointScoredPlayer
@onready var game_over_player : AudioStreamPlayer = $GameOverPlayer
# Parallaxes
@onready var sky_parallax : Parallax2D = $AreaSky
@onready var sky_sprite : Sprite2D = $AreaSky/SkySprite

@onready var far_parallax : Parallax2D = $AreaFarDetails
@onready var far_sprite : Sprite2D = $AreaFarDetails/FarSprite

@onready var close_parallax : Parallax2D = $AreaCloseDetails
@onready var close_sprite : Sprite2D = $AreaCloseDetails/CloseSprite

@onready var floor_parallax : Parallax2D = $Floor/Parallax2D
@onready var floor_sprite : Sprite2D = $Floor/Parallax2D/FloorSprite

# Parallax references
const area_rects : Array[Rect2] = [
	Rect2(0, 0, 640, 320),
	Rect2(0, 320, 640, 320),
	Rect2(0, 640, 640, 320),
	Rect2(0, 960, 640, 320),
	Rect2(0, 1280, 640, 320)
]
const floor_rects : Array[Rect2] = [
	Rect2(0, 0, 640, 32),
	Rect2(0, 32, 640, 32),
	Rect2(0, 64, 640, 32),
	Rect2(0, 96, 640, 32),
	Rect2(0, 128, 640, 32),
]
# Game state
var points := 0
var record := 0
var last_area := 0
var just_started := false
# Animations
var tween1 : Tween
const time1 := 1.0

func _ready():
	_load_record()
	stop_parallaxes()

# Wait for initial press to enable the bird, only at game start.
func _unhandled_input(event):
	if event.is_action("bird_jump"):
		set_process_unhandled_input(false)
		bird_node.enable_bird()
		hud_node.hide_anim()
		wall_manager.start_walls()
		start_parallaxes()

# Game state control

## Show game over mini menu
func game_over() -> void:
	game_over_player.play()
	hud_node.show_anim()
	wall_manager.stop_walls()
	stop_parallaxes()

## Restarts game states
func restart_game() -> void:
	points = 0
	last_area = 0
	hud_node.update_point_counter()
	wall_manager.restart_walls()
	wall_manager.start_walls()
	bird_node.restart_bird()
	bird_node.enable_bird()
	start_parallaxes()
	set_parallax_area(0,true)
	# This prevents scoring point right when a game is restarted by leaving the collided wall.
	just_started = true
	await get_tree().create_timer(1.0).timeout
	just_started = false

func point_scored() -> void:
	if just_started:
		return
	point_scored_player.play()
	points += 1
	hud_node.update_point_counter()
	# Change the parallax to the relevant area
	if points >= 50 and points < 150 and last_area != 1:
		set_parallax_area(1)
	elif points >= 150 and points < 300 and last_area != 2:
		set_parallax_area(2)
	elif points >= 300 and points < 450 and last_area != 3:
		set_parallax_area(3)
	elif points >= 450 and last_area != 4:
		set_parallax_area(4)

# Parallax control

func start_parallaxes() -> void:
	sky_parallax.autoscroll.x = -16
	far_parallax.autoscroll.x = -32
	close_parallax.autoscroll.x = -48
	floor_parallax.autoscroll.x = -200

## Changes the parallax environment aera [Field, Forest, Temple, Sky, OldCity]
func set_parallax_area(area:int,instant:bool = false) -> void:
	last_area = area
	if instant:
		sky_sprite.texture.region = area_rects[area]
		far_sprite.texture.region = area_rects[area]
		close_sprite.texture.region = area_rects[area]
		floor_sprite.texture.region = floor_rects[area]
		return
	# Change parallaxes with animations
	if tween1:
		tween1.kill()
	tween1 = create_tween()
	tween1.set_parallel()
	
	tween1.tween_property(sky_sprite,"modulate", Color.TRANSPARENT, time1).set_delay(0)
	tween1.tween_property(far_sprite,"modulate", Color.TRANSPARENT, time1).set_delay(1)
	tween1.tween_property(close_sprite,"modulate", Color.TRANSPARENT, time1).set_delay(2)
	tween1.tween_property(floor_sprite,"modulate", Color.TRANSPARENT, time1).set_delay(3)
	
	tween1.set_trans(Tween.TRANS_CUBIC)
	tween1.set_ease(Tween.EASE_OUT)
	tween1.tween_property(sky_sprite,"texture:region", area_rects[area], time1).set_delay(time1 + 0)
	tween1.tween_property(far_sprite,"texture:region", area_rects[area], time1).set_delay(time1 + 1)
	tween1.tween_property(close_sprite,"texture:region", area_rects[area], time1).set_delay(time1 + 2)
	tween1.tween_property(floor_sprite,"texture:region", floor_rects[area], time1).set_delay(time1 + 3)
	
	tween1.set_trans(Tween.TRANS_LINEAR)
	tween1.set_ease(Tween.EASE_IN_OUT)
	tween1.tween_property(sky_sprite,"modulate", Color.WHITE, 1.0).set_delay(time1 * 2 + 0)
	tween1.tween_property(far_sprite,"modulate", Color.WHITE, 1.0).set_delay(time1 * 2 + 1)
	tween1.tween_property(close_sprite,"modulate", Color.WHITE, 1.0).set_delay(time1 * 2 + 2)
	tween1.tween_property(floor_sprite,"modulate", Color.WHITE, 1.0).set_delay(time1 * 2 + 3)

func stop_parallaxes() -> void:
	sky_parallax.autoscroll.x = 0
	far_parallax.autoscroll.x = 0
	close_parallax.autoscroll.x = 0
	floor_parallax.autoscroll.x = 0

# Record persistence

func _load_record() -> void:
	# Case 1 -> No previous record file, start at 0
	if not FileAccess.file_exists("user://record.save"):
		print("No previous record file found, creating new one.")
		_create_record_file()
		record = 0
		return
	# Case 2 -> Previous record file found, load value.
	else:
		var old_save := FileAccess.open("user://record.save",FileAccess.READ)
		record = old_save.get_64()
		old_save.close()
		print("Loaded previous record: ",record)
	
	# Update HUD record
	hud_node.record_score_label.text = str(record)

func save_record() -> void:
	var save_file := FileAccess.open("user://record.save",FileAccess.WRITE)
	save_file.store_64(record)
	save_file.close()
	print("Saved record: ",record)

func _create_record_file() -> void:
	var new_file := FileAccess.open("user://record.save",FileAccess.WRITE)
	new_file.store_64(0)
	new_file.close()
