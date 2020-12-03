extends Node2D

var cursor_position = Vector2()
export(PoolVector2Array) var  oui
onready var player = get_tree().get_current_scene().get_node("player") 

func _process(delta):
	$Tween.interpolate_property($Sprite,"position",$Sprite.global_position,get_global_mouse_position(),0.8,Tween.TRANS_EXPO,Tween.EASE_OUT)
	$Tween.start()
	cursor_position = $Sprite.position
	$Sprite.rotation_degrees = player.rotation_degrees
