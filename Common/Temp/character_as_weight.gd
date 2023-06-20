extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var gravity_mod := 1.0
@export var terminal_speed := 4000.0

@export var on_floor_friction := 0.25
@export var in_air_friction := 0.2


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * gravity_mod * delta
	
	apply_friction()
	clamp_terminal_speed()
	
	move_and_slide()
	
#	print("CharacterAsWeight: " , velocity)


func apply_friction() -> void:
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, on_floor_friction)
		
	else:
		velocity.x = lerp(velocity.x, 0.0, in_air_friction)


func clamp_terminal_speed() -> void:
#	velocity.x = clamp(velocity.x, -terminal_speed, terminal_speed)
#	velocity.y = clamp(velocity.y, -terminal_speed, terminal_speed)
	
	velocity = velocity.normalized() * clamp(velocity.length(), 0.0, terminal_speed)
