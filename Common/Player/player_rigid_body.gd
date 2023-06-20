# Player RigidBody2D
# ----------------------------------------

extends RigidBody2D
class_name PlayerRigidBody


# Variables:
#---------------------------------------
@onready var movement := %PlayerMovementRigidBody
@onready var player_sprite := %Sprite2D
@onready var ground_ray := %GroundCheck

var input_dir := Vector2.ZERO


# Functions:
#---------------------------------------
func _ready() -> void:
	movement.init(self)
	

func _unhandled_input(event: InputEvent) -> void:
	# movement
	if event.is_action_pressed("move_left"):
		input_dir.x -= 1
	if event.is_action_released("move_left"):
		input_dir.x += 1
	if event.is_action_pressed("move_right"):
		input_dir.x += 1
	if event.is_action_released("move_right"):
		input_dir.x -= 1
		
	# jump
	if event.is_action_pressed("ui_accept"):
		movement.jump()


func update_sprite(dir : Vector2) -> void:
	if dir.x > 0:
		player_sprite.flip_h = false
		
	elif dir.x < 0:
		player_sprite.flip_h = true


func is_on_floor() -> bool:
	return ground_ray.is_colliding()


func _process(delta: float) -> void:
	update_sprite(input_dir)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	movement.move_player(state.step, input_dir)
