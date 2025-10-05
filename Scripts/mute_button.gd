extends TextureButton

@onready var music = get_node("/root/Music")

func _ready() -> void:
	set_pressed_no_signal(music.mute)

func _on_toggled(toggled_on: bool) -> void:
	music.mute = toggled_on
