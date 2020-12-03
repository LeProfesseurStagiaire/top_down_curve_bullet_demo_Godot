extends KinematicBody2D

onready var bullet_load = preload("res://scenes/bullet.tscn")
onready var curve = Curve2D.new()
onready var line_manager = get_tree().get_current_scene().get_node("line_manager")
onready var cursor_to_follow = get_tree().get_current_scene().get_node("cursor_follower_manager")
var speed = 5
var shoot_pressed = false
var actual_time_scale = 1
var max_time_scale_change = 0.2
var min_value_to_curve = 30

var curve_deformation_strength = 400

func _ready():
	
	#create curve points
	curve.add_point(Vector2(0,0))
	curve.add_point(Vector2(0,0))

func _process(delta):
	#move
	var dir = Vector2(0,0)
	if Input.is_action_pressed("ui_down"):
		dir.y = speed
	if Input.is_action_pressed("ui_up"):
		dir.y = -speed
	if Input.is_action_pressed("ui_left"):
		dir.x = -speed
	if Input.is_action_pressed("ui_right"):
		dir.x = speed
	move_and_collide(dir*actual_time_scale)
	
	#set curve points
	curve.set_point_position(1,cursor_to_follow.cursor_position-global_position)
	
	#set player position and rotation from mouse position
	var initial_transform_x = self.transform.x
	var final_transform_x = (cursor_to_follow.cursor_position - self.global_position).normalized()
	var dif = final_transform_x-initial_transform_x
	
	#set bezier points / clamp is used to limit the curve streight when too close and far form the player 
	curve.set_point_in(1,Vector2(curve_deformation_strength*dif.x,curve_deformation_strength*dif.y)*-1*clamp(position.distance_to(cursor_to_follow.cursor_position)*0.005,0,1))
	curve.set_point_in(0,Vector2(300*dif.x,300*dif.y)*-1*clamp(position.distance_to(cursor_to_follow.cursor_position)*0.005,0,1))

	#refresh line 
	line_manager.set_curve_to_line(curve)
	
	#change player rotation
	$rotation_change.interpolate_method(self,"_set_rotation", initial_transform_x, final_transform_x, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$rotation_change.start()
	
	#shoot
	if Input.is_action_just_pressed("shoot"):
		shoot_pressed = true
		$slow_motion_launch_timer.start(0.5)
	if Input.is_action_just_released("shoot"):
		shoot_pressed = false
		shoot()
		$slow_motion.stop_all()
		$slow_motion.interpolate_property(self,"actual_time_scale",actual_time_scale,1,0.02,Tween.TRANS_EXPO,Tween.EASE_IN)
		$slow_motion.interpolate_property($Camera2D,"zoom",$Camera2D.zoom,Vector2(1,1),0.1,Tween.TRANS_LINEAR,Tween.EASE_IN)
		$slow_motion.start()
		$slow_motion_launch_timer.stop()
	Engine.time_scale = actual_time_scale

func shoot():
	var bullet_instance = bullet_load.instance()
	if (position + curve.get_point_in(0)).distance_to(position) > min_value_to_curve:
		bullet_instance.curve_to_follow = curve.duplicate()
		bullet_instance.position = position
	else:
		bullet_instance.curve_to_follow = Curve2D.new()
		bullet_instance.curve_to_follow.add_point(position)
		bullet_instance.curve_to_follow.add_point(position + curve.tessellate()[curve.tessellate().size()-1])
	get_tree().get_current_scene().add_child(bullet_instance)

#function to change player rotation
func _set_rotation(new_transform):
	self.transform.x = new_transform
	
	# make x and y orthogonal and normalized
	self.transform = self.transform.orthonormalized()

func _on_slow_motion_launch_timer_timeout():
	$slow_motion.stop_all()
	$slow_motion.interpolate_property(self,"actual_time_scale",actual_time_scale,max_time_scale_change,0.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$slow_motion.interpolate_property($Camera2D,"zoom",$Camera2D.zoom,Vector2(0.9,0.9),0.4,Tween.TRANS_EXPO,Tween.EASE_OUT)
	$slow_motion.start()
