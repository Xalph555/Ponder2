# Player Movement

# the purpose of this class is to control the movement of a player character 
# ----------------------------------------

extends Node
class_name PlayerMovement

# Variables:
#---------------------------------------
var player : CharacterBody2D

@export_subgroup("Movement")
@export var terminal_speed := 4000.0
@export var acceleration:= 50.0

@export var max_speed := 400.0
@onready var limit_speed := max_speed

@export var limit_max_transition := 0.2

@export var on_floor_friction := 0.25
@export var in_air_friction := 0.2

@export_subgroup("Jump")
@export var jump_height := 38.0:
	set(new_value):
		jump_height = new_value
		update_jump_variables()
	get:
		return jump_height

@export var jump_time_to_peak := 0.4:
	set(new_value):
		jump_time_to_peak = new_value
		update_jump_variables()
	get:
		return jump_time_to_peak

@export var jump_time_to_descent := 0.4:
	set(new_value):
		jump_time_to_descent = new_value
		update_jump_variables()
	get:
		return jump_time_to_descent
	
var _jump_velocity : float
var _jump_gravity : float
var _fall_gravity : float

var _can_jump := false

@export var jump_buffer = 0.1
var _jump_buffer_timer := 0.0

@export var coyote_delay = 0.2
var _coyote_timer := 0.0
var _has_set_coyote := false


# Functions:
#---------------------------------------
func init(char : CharacterBody2D) -> void:
	player = char
	update_jump_variables()


func _physics_process(delta: float) -> void:
	if player.is_on_floor() and _can_jump != true:
		_can_jump = true
	
	if player.is_on_floor():
		_has_set_coyote = false
	
	# jump buffer
	if _jump_buffer_timer > 0.0:
		_jump_buffer_timer -= delta
		
		if player.is_on_floor():
			jump()

	# coyote timer
	if not player.is_on_floor() and not _has_set_coyote:
		_coyote_timer = coyote_delay
		_has_set_coyote = true
	
	if _coyote_timer > 0.0:
		_coyote_timer -= delta


func move_player(delta : float, dir := Vector2.ZERO) -> void:
	dir = dir.normalized()
	
	if not player.is_on_floor():
		player.velocity.y += get_gravity() * delta
	
	player.velocity.x = clamp(player.velocity.x + dir.x * acceleration, -limit_speed, limit_speed)
	limit_speed = lerp(limit_speed, max_speed, limit_max_transition)
	
	apply_friction()
	
	clamp_terminal_speed()
	
	player.move_and_slide()
	
#	print("Player Vel: ", player.velocity.length())


func apply_friction() -> void:
	if player.is_on_floor():
		player.velocity.x = lerp(player.velocity.x, 0.0, on_floor_friction)
		
	else:
		player.velocity.x = lerp(player.velocity.x, 0.0, in_air_friction)


func clamp_terminal_speed() -> void:
#	player.velocity.x = clamp(player.velocity.x, -terminal_speed, terminal_speed)
#	player.velocity.y = clamp(player.velocity.y, -terminal_speed, terminal_speed)

	player.velocity = player.velocity.normalized() * clamp(player.velocity.length(), 0.0, terminal_speed)


func get_gravity() -> float:
	return _jump_gravity if player.velocity.y < 0.0 else _fall_gravity
	

func jump() -> void:
	if not _can_jump:
		if _jump_buffer_timer <= 0.0:
			_jump_buffer_timer = jump_buffer
		return
		
	if player.is_on_floor() or _coyote_timer > 0:
		# correction for "super jump" bug
		if (player.velocity.y != 0):
			player.velocity.y -= player.velocity.y
			
		player.velocity.y += _jump_velocity
		_can_jump = false
		_has_set_coyote = false


func update_jump_variables() -> void:
	_jump_velocity = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
	_jump_gravity = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
	_fall_gravity = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

