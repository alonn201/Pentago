extends Control

@onready var music = get_node("/root/Music")

@export var normal_volume_db := 0.0
	  
var muted := false 

func _on_mute_button_pressed() -> void:
	muted = not muted
	music.volume_db = -80.0 if muted else normal_volume_db
