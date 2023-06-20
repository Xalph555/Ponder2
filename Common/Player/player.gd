# Player 
# ----------------------------------------

extends CharacterBody2D
class_name Player

# Variables:
#---------------------------------------
@export var movement : PlayerMovement
@export var player_sprite : Sprite2D

var input_dir := Vector2.ZERO


# Functions:
#---------------------------------------
func _ready() -> void:
	movement.init(self)


#func get_movement_input() -> Vector2:
#	var input_dir = Vector2.ZERO
#
#	if Input.is_action_pressed("move_left"):
#		input_dir.x = -1
#
#	if Input.is_action_pressed("move_right"):
#		input_dir.x = 1
#
#	return input_dir
	

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


func _process(delta: float) -> void:
	update_sprite(input_dir)


func _physics_process(delta):
	# if Input.is_action_just_pressed("ui_accept"):
	# 	movement.jump()

	movement.move_player(delta, input_dir)

