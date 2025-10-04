extends AudioStreamPlayer

const MUTE_VOLUME = -80.0
const UNMUTE_VOLUME = 0.0

@export var mute: bool:
	get():
		return volume_db == MUTE_VOLUME
	set(volume):
		volume_db = MUTE_VOLUME if volume else UNMUTE_VOLUME
