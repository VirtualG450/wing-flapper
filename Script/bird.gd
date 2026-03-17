extends CharacterBody2D
class_name Bird
# Game references
@onready var game_manager : GameManager = $".."
@onready var floor_body = %Floor
# Bird references
@onready var bird_sprite : Sprite2D = $Body

# Movement settings
const jump_force := 8.0
const fall_force := 16.0
var is_dead := false
# Animations
var tween1 : Tween
const time1 := 0.3

# Initial state and bird enable/disable

func _ready():
	restart_bird()
	disable_bird()

## Restores the initial state of the bird.
func restart_bird() -> void:
	global_position.y = get_viewport_rect().get_center().y
	velocity.y = 0
	is_dead = false
	bird_sprite.texture.region.position.x = 64

func enable_bird() -> void:
	set_physics_process(true)

func disable_bird() -> void:
	set_physics_process(false)

# Movement

func _unhandled_input(event):
	if event.is_action_pressed("bird_jump"):
		velocity.y = -jump_force
		_wing_flap()

func _physics_process(delta):
	velocity.y += fall_force * delta
	velocity.y = clampf(velocity.y, -fall_force * 2, fall_force * 2)
	_check_collider( move_and_collide(velocity) )

func _check_collider(collision:KinematicCollision2D) -> void:
	if not collision:
		return
	var body : StaticBody2D = collision.get_collider()
	if body == floor_body or body.is_in_group("Walls"):
		disable_bird()
		game_manager.game_over()

# Animations

func _wing_flap() -> void:
	bird_sprite.texture.region.position.x = 64
	if tween1:
		tween1.kill()
	tween1 = create_tween()
	tween1.tween_interval(0.1)
	tween1.tween_property(bird_sprite,"texture:region:position:x",0, 0)
	tween1.tween_interval(time1)
	tween1.tween_property(bird_sprite,"texture:region:position:x",64, 0)
