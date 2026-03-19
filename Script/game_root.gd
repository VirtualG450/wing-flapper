extends Node2D
class_name GameManager
# Other nodes
@onready var bird_node : Bird = $Bird
@onready var hud_node : HUDLayer = $HUD
@onready var wall_manager : WallManager = $WallManager
# Parallaxes
@onready var sky_parallax : Parallax2D = $AreaSky
@onready var sky_sprite : Sprite2D = $AreaSky/SkySprite

@onready var far_parallax : Parallax2D = $AreaFarDetails
@onready var far_sprite : Sprite2D = $AreaFarDetails/FarSprite

@onready var close_parallax : Parallax2D = $AreaCloseDetails
@onready var close_sprite : Sprite2D = $AreaCloseDetails/CloseSprite

@onready var floor_parallax : Parallax2D = $Floor/Parallax2D
@onready var floor_sprite : Sprite2D = $Floor/Parallax2D/FloorSprite

@onready var decor_parallax : Parallax2D = $AreaDecor
@onready var decor_sprite : Sprite2D = $AreaDecor/AreaSprite

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
var points := 156
var last_area := 0
# Animations
var tween1 : Tween
const time1 := 1.0

func _ready():
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
	hud_node.show_anim()
	wall_manager.stop_walls()
	stop_parallaxes()

## Restarts game states
func restart_game() -> void:
	points = 0
	last_area = 0
	hud_node.update_point_coutner()
	wall_manager.restart_walls()
	wall_manager.start_walls()
	bird_node.restart_bird()
	bird_node.enable_bird()
	start_parallaxes()
	set_parallax_area(0,true)

func point_scored() -> void:
	points += 1
	hud_node.update_point_coutner()
	# Change the parallax to the relevant area
	if points >= 50 and points < 150 and last_area != 1:
		set_parallax_area(1)
	elif points >= 150 and points < 300 and last_area != 2:
		set_parallax_area(2)
	elif points >= 300 and points < 450 and last_area != 3:
		set_parallax_area(3)
	elif points >= 450 and points < 600 and last_area != 4:
		set_parallax_area(4)

# Parallax control

func start_parallaxes() -> void:
	sky_parallax.autoscroll.x = -16
	far_parallax.autoscroll.x = -32
	close_parallax.autoscroll.x = -48
	decor_parallax.autoscroll.x = -64
	floor_parallax.autoscroll.x = -200

## Changes the parallax environment aera [Farm, Forest, Temple, Sky, Space]
func set_parallax_area(area:int,instant:bool = false) -> void:
	last_area = area
	if instant:
		sky_sprite.texture.region = area_rects[area]
		far_sprite.texture.region = area_rects[area]
		close_sprite.texture.region = area_rects[area]
		floor_sprite.texture.region = floor_rects[area]
		decor_sprite.texture.region = area_rects[area]
		return
	# Change parallaxes with animations
	if tween1:
		tween1.kill()
	tween1 = create_tween()
	tween1.set_parallel()
	
	#tween1.tween_property(sky_sprite,"modulate", Color.TRANSPARENT, time1).set_delay(0)
	#tween1.tween_property(far_sprite,"modulate", Color.TRANSPARENT, time1).set_delay(1)
	#tween1.tween_property(close_sprite,"modulate", Color.TRANSPARENT, time1).set_delay(2)
	#tween1.tween_property(floor_sprite,"modulate", Color.TRANSPARENT, time1).set_delay(3)
	#tween1.tween_property(decor_sprite,"modulate", Color.TRANSPARENT, time1).set_delay(4)
	
	tween1.set_trans(Tween.TRANS_CUBIC)
	tween1.set_ease(Tween.EASE_OUT)
	tween1.tween_property(sky_sprite,"texture:region", area_rects[area], time1).set_delay(time1 + 0)
	tween1.tween_property(far_sprite,"texture:region", area_rects[area], time1).set_delay(time1 + 1)
	tween1.tween_property(close_sprite,"texture:region", area_rects[area], time1).set_delay(time1 + 2)
	tween1.tween_property(floor_sprite,"texture:region", floor_rects[area], time1).set_delay(time1 + 3)
	tween1.tween_property(decor_sprite,"texture:region", area_rects[area], time1).set_delay(time1 + 4)
	
	#tween1.set_trans(Tween.TRANS_LINEAR)
	#tween1.set_ease(Tween.EASE_IN_OUT)
	#tween1.tween_property(sky_sprite,"modulate", Color.WHITE, 1.0).set_delay(time1 * 2 + 0)
	#tween1.tween_property(far_sprite,"modulate", Color.WHITE, 1.0).set_delay(time1 * 2 + 1)
	#tween1.tween_property(close_sprite,"modulate", Color.WHITE, 1.0).set_delay(time1 * 2 + 2)
	#tween1.tween_property(floor_sprite,"modulate", Color.WHITE, 1.0).set_delay(time1 * 2 + 3)
	#tween1.tween_property(decor_sprite,"modulate", Color.WHITE, 1.0).set_delay(time1 * 2 + 4)

func stop_parallaxes() -> void:
	sky_parallax.autoscroll.x = 0
	far_parallax.autoscroll.x = 0
	close_parallax.autoscroll.x = 0
	decor_parallax.autoscroll.x = 0
	floor_parallax.autoscroll.x = 0
