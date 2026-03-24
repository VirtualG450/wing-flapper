extends Node2D
class_name WallManager
# References
@onready var game_manager : GameManager = $".."
var wall_nodes : Array[StaticBody2D] = []
var wall_scene : PackedScene = preload("uid://3xu8bkear3fj")
# Wall behaviour
const wall_speed := 160.0
const y_range : Array[float] = [62, 210]
const wall_spacing := 220.0
var last_wall : StaticBody2D
const wall_rects : Array[Rect2] = [
	Rect2(0, 0, 32, 480),
	Rect2(32, 0, 32, 480),
	Rect2(64, 0, 32, 480),
	Rect2(96, 0, 32, 480),
	Rect2(128, 0, 32, 480),
]

# Initial loading

func _ready():
	set_process(false)
	_create_walls()

func _create_walls() -> void:
	var last_pos := 640.0 + 16
	for i in 5:
		var new_wall : StaticBody2D = wall_scene.instantiate()
		var score_area : Area2D = new_wall.get_node("ScoreArea")
		score_area.body_exited.connect(_bird_passed)
		new_wall.global_position.x = last_pos
		last_pos += wall_spacing
		_reposition_wall(new_wall, true)
		add_child(new_wall)
		wall_nodes.append(new_wall)
	last_wall = wall_nodes[ wall_nodes.size() - 1 ]

# Wall restart after game over

## Repositions all walls to the right, randomizes Y and retextures.
func restart_walls() -> void:
	var last_pos := 640.0 + 16.0
	for wall in wall_nodes:
		wall.global_position.x = last_pos
		last_pos += wall_spacing
		_reposition_wall(wall, true)
		_retexture_wall(wall)
	last_wall = wall_nodes[ wall_nodes.size() - 1 ]

# Main behaviour control

func start_walls() -> void:
	set_process(true)

func stop_walls() -> void:
	set_process(false)

# Main behaviour loop

func _process(delta):
	_move_walls(delta)

## Move the walls towards left, reposition to right and randomize Y position, update texture.
func _move_walls(delta:float) -> void:
	for wall in wall_nodes:
		# Move the wall to the left over time
		wall.global_position.x -= wall_speed * delta
		# Reposition to right when left is reached
		if wall.global_position.x <= -32:
			_reposition_wall(wall)
			_retexture_wall(wall)

## Repositions the wall to the right side and randomizes height.
func _reposition_wall(wall:StaticBody2D, only_height:bool = false) -> void:
	if not only_height:
		wall.global_position.x = last_wall.global_position.x + wall_spacing
		last_wall = wall
	wall.global_position.y = randf_range( y_range[0], y_range[1] )

## Changes given wall's texture based on game_manager current points.
func _retexture_wall(wall:StaticBody2D) -> void:
	# Get sprite reference
	var wall_texture : Sprite2D = wall.get_node_or_null("WallSprite")
	# Change texture to the relevant area
	if game_manager.last_area == 0:
		wall_texture.texture.region = wall_rects[0]
	elif game_manager.last_area == 1:
		wall_texture.texture.region = wall_rects[1]
	elif game_manager.last_area == 2:
		wall_texture.texture.region = wall_rects[2]
	elif game_manager.last_area == 3:
		wall_texture.texture.region = wall_rects[3]
	elif game_manager.last_area == 4:
		wall_texture.texture.region = wall_rects[4]

# Bird pass

func _bird_passed(_body:Node2D) -> void:
	
	game_manager.point_scored()
