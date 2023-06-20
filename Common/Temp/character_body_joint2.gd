extends Node2D

@export var character : CharacterBody2D
@export var parent : CharacterBody2D

@export_subgroup("Joint")
@export var joint_distance := 100
@export var spring_tightness = 0.9
@export var damp = 0.9

@export_subgroup("Swing")
@export var pendulumn_fall := 0.25
@export var push_force := 0.065
@export var swing_speed := 100.0
@export var max_swing_speed := 500.0
@export var grapple_adjustment_force := 60.0

var current_dist := 0.0


var rot_dir = 0.0
var previous_vel := Vector2.ZERO

var angular_vel := 0.0
var has_converted := false
var applying_grapple := false


func _draw() -> void:
	if !character:
		return
		
	var dir = self.global_position.direction_to(character.global_position)
	
	draw_line(to_local(self.global_position), dir * joint_distance, Color.RED, 2)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_settings"):
		self.queue_free()


func _process(delta: float) -> void:
	queue_redraw()


func _physics_process(delta: float) -> void:
	if not character || not parent:
		return
		
	current_dist = self.global_position.distance_to(character.global_position)
	var dir = character.global_position.direction_to(self.global_position)
	
	if current_dist > joint_distance:
		var has_moved_character := true
		
		# apply force to character
		
#		if Vector2.DOWN.dot(self.global_position.direction_to(character.global_position)) > -0.1 and not character.is_on_floor():
#		if is_equal_approx(parent.velocity.length(), 0.0):
		if parent.is_on_floor() and not character.is_on_floor():
			if !has_converted:
				angular_vel = convert_to_angular_vel(character.velocity)
				has_converted = true
				
			if not apply_pendulum_force(delta, character, self.global_position):
				has_converted = false
				has_moved_character = false
			else:
				print("applying force to character")
			
		else:
			if not apply_normal_pull_force(delta, character, self.global_position):
				has_moved_character = false
			else:
				has_converted = false
				print("applying force to character")
		
		# apply force to parent
		if not has_moved_character:
			if character.is_on_floor() and not parent.is_on_floor():
				if !has_converted:
					angular_vel = convert_to_angular_vel(parent.velocity)
					has_converted = true
					
				apply_pendulum_force(delta, parent, character.global_position, true)
			
			else:
				has_converted = false
				
				apply_normal_pull_force(delta, parent, character.global_position, true)
				
			print("applying force to parent")
		
		print("----------")
		
	else:
		has_converted = false


func convert_to_angular_vel(cur_vec_vel : Vector2) -> float:
#	return sign(cur_vec_vel.x) * (cur_vec_vel.length() / (swing_speed * clamp(joint_distance / 100.00, 0.4, 1.0)))
	print("converting angular vel")
	return cur_vec_vel.length() / joint_distance


func apply_pendulum_force(delta : float, target : CharacterBody2D, dest_point : Vector2, skip_test := false) -> bool:
	var angle_accel = -pendulumn_fall * cos(dest_point.direction_to(target.global_position).angle())
	
#		print(cos(self.global_position.direction_to(character.global_position).angle()))

#			var angular_velocity = convert_to_angular_vel(character.velocity) + angle_accel
#			angular_velocity *= 0.99

	angular_vel += angle_accel
	angular_vel *= 0.99
	
	var hook_dir := target.global_position.direction_to(dest_point)
	var p_hook_dir := Vector2(sign(angular_vel) * -hook_dir.y, sign(angular_vel) * hook_dir.x).normalized()
	var new_vel = p_hook_dir * abs(angular_vel) * (swing_speed * clamp(joint_distance / 100.00, 0.4, 1.0))

	var dist_factor := (current_dist - joint_distance) as float
	var adjust_force := (dist_factor * hook_dir * grapple_adjustment_force) as Vector2
	
	var dir_dot = Vector2.DOWN.dot(dest_point.direction_to(target.global_position))
	
	new_vel += adjust_force * clamp(dir_dot, 0.0, 1.0)
	
	if target.test_move(target.get_transform(), new_vel * delta * 2) and not skip_test:
		return false

	target.velocity = new_vel
	
	print("applying pendulum")
	
	return true


func apply_normal_pull_force(delta : float, target : CharacterBody2D, dest_point : Vector2, skip_test := false) -> bool:
	var position_to_move_to = dest_point + (dest_point.direction_to(target.global_position) * joint_distance)
	var displacement = position_to_move_to - target.global_position

	if target.test_move(target.get_transform(), displacement.normalized()) and not skip_test:
		return false
		
	target.global_position = position_to_move_to
	
#	target.velocity = position_to_move_to.normalized() * displacement * (1 + ((current_dist - joint_distance) / joint_distance))

	
	print("applying normal pull")
	
	return true



func old() -> void:
	#		print(character.velocity)
	#		print("outside joint distance")
		
	#		character.velocity -= character.velocity
		
	if false:
		var position_to_move_to = self.global_position + (self.global_position.direction_to(character.global_position) * joint_distance)
		var displacement = position_to_move_to - character.global_position

		character.global_position = position_to_move_to
		
		var normal = self.global_position.direction_to(character.global_position).normalized()
		rot_dir += cos(self.global_position.direction_to(character.global_position).angle())
		
		var vel_target_dir = normal.rotated((PI/2.0) * sign(rot_dir))
		
		character.velocity = (character.velocity.length()) * vel_target_dir
	#		character.velocity *= 0.6

	#		previous_vel = character.velocity 
			
	#		print(character.velocity)
	#		print(character.velocity.length())
	#		print(rot_dir)
