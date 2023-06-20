extends Node2D

@export var character : CharacterBody2D

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
	if !character:
		return
		
	var dist = self.global_position.distance_to(character.global_position)
	var dir = character.global_position.direction_to(self.global_position)
	
#	character.velocity += (dist / joint_distance) * dist * dir

	
	
	if dist > joint_distance:
		var vel_to_apply := Vector2.ZERO
		
#		if character.test_move(character.transform, displacement * delta):
#			print("cannot apply desired displacement without collision")
#		else:
#			character.global_position = position_to_move_to
		
		
#		character.velocity += (dist - joint_distance) * dir

#		vel_to_apply += ((dist - joint_distance) * dir * spring_tightness) + (-1 * character.velocity * damp)
		vel_to_apply += (((dist - joint_distance) * spring_tightness) + (character.velocity.length() * damp)) * dir
		
#		print("spring: ", ((dist - joint_distance) * spring_tightness))
#		print("velocity: ", (character.velocity.length() * damp))
		
#		var angle_accel = -pendulumn_fall * cos(self.global_position.direction_to(character.global_position).angle())
#
#		var angular_velocity = convert_to_angular_vel(character.get_real_velocity()) + angle_accel
#		angular_velocity *= 0.99
#
#		var hook_dir := character.global_position.direction_to(self.global_position)
#		var p_hook_dir := Vector2(sign(angular_velocity) * -hook_dir.y, sign(angular_velocity) * hook_dir.x).normalized()
#
#		vel_to_apply += p_hook_dir * abs(angular_velocity)
		
		character.velocity += vel_to_apply


#func get_swing_force() -> Vector2:
#	# applying pendulum angle acceleration
#	var angle_accel = -pendulumn_fall * cos(self.global_position.direction_to(character.global_position).angle())
#
##	angle_accel += grapple_params.push_dir.x * push_force
#	angular_velocity += angle_accel
#	angular_velocity *= 0.99
#
#	var hook_dir := character.global_position.direction_to(self.global_position)
#	var p_hook_dir := Vector2(sign(angular_velocity) * -hook_dir.y, sign(angular_velocity) * hook_dir.x).normalized()
#	var s_force := p_hook_dir * abs(angular_velocity) as Vector2
#
#	# adjust to meet max_line_length
##	var dist_factor := (grapple_params.current_dist - grapple_params.max_line_tension) as float
##	var adjust_force := (dist_factor * hook_dir * grapple_adjustment_force) as Vector2
##	s_force += adjust_force
#
#	return s_force


func convert_to_angular_vel(cur_vec_vel : Vector2) -> float:
	return sign(cur_vec_vel.x) * (cur_vec_vel.length() / (10 * clamp(joint_distance / 100.00, 0.4, 1.0)))
