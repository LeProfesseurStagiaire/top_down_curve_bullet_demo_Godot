extends Node2D

onready var curve_to_follow
var speed = 2000

func _ready():
	$Path2D.curve = curve_to_follow
	$Path2D.curve.add_point($Path2D.curve.tessellate()[$Path2D.curve.tessellate().size()-1] + ($Path2D.curve.tessellate()[$Path2D.curve.tessellate().size()-1] -$Path2D.curve.tessellate()[$Path2D.curve.tessellate().size()-2])*10000)
	
	$pre_line.points = curve_to_follow.tessellate()
	$pre_line_transparent.interpolate_property($pre_line,"modulate",$pre_line.modulate,Color(0,0,0,0),3.5,Tween.TRANS_EXPO,Tween.EASE_OUT)
	$pre_line_transparent.start()

func _process(delta):
	$Path2D/PathFollow2D.offset += speed*delta

func _on_VisibilityNotifier2D_screen_exited():
	kill_bullet()


func _on_Area2D_body_entered(body):
	if body.get_class() == "StaticBody2D":
		kill_bullet()

func kill_bullet():
	queue_free()
