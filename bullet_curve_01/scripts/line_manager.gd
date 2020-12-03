extends Node2D

onready var player = get_tree().get_current_scene().get_node("player")

func set_curve_to_line(curve):
	var curve_pool = curve.tessellate()
	$Line2D.global_position = player.global_position
	$Line2D.points = curve_pool
	
	#only used for visual management
	$bezier_manage_1/bezier_point.position = player.position + curve.get_point_in(0)
	$bezier_manage_1/bezier_point.rotation_degrees = player.rotation_degrees
	$bezier_manage_1/bezier_line.set_point_position(0,$bezier_manage_1/bezier_point.position)
	$bezier_manage_1/bezier_line.set_point_position(1,player.position)
	$bezier_manage_1/txt.rect_position = player.position + curve.get_point_in(0) + Vector2(10,10)
	$bezier_manage_1/txt.text = str(int($bezier_manage_1/bezier_point.position.distance_to(player.position)))
	
	$bezier_manage_2/bezier_point.position = player.position + curve_pool[curve_pool.size()-1] + curve.get_point_in(1)
	$bezier_manage_2/bezier_point.rotation_degrees = player.rotation_degrees
	$bezier_manage_2/bezier_line.set_point_position(0,$bezier_manage_2/bezier_point.position)
	$bezier_manage_2/bezier_line.set_point_position(1,player.position + curve_pool[curve_pool.size()-1])
	$bezier_manage_2/txt.rect_position = player.position + curve_pool[curve_pool.size()-1] + curve.get_point_in(1) + Vector2(10,10)
	$bezier_manage_2/txt.text = $bezier_manage_1/txt.text
	
	if int($bezier_manage_2/txt.text) > player.min_value_to_curve:
		$bezier_manage_2/txt.modulate = Color(0,1,0)
		$bezier_manage_1/txt.modulate = Color(0,1,0)
	else:
		$bezier_manage_2/txt.modulate = Color(1,0,0)
		$bezier_manage_1/txt.modulate = Color(1,0,0)
	
	$line_to_player.set_point_position(0,player.position)
	$line_to_player.set_point_position(1,player.position + curve_pool[curve_pool.size()-1])
