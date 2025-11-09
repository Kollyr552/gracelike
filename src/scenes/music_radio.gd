extends Node3D

@onready var stream_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var is_playing: bool = false
var playback_pos: float = 0.0
@export var unpause_rewind: float = 0.6

func _on_interactible_box_action_triggered() -> void:
	is_playing = not is_playing
	if is_playing:
		stream_player.play(max(playback_pos - unpause_rewind, 0.0))
	else:
		playback_pos = stream_player.get_playback_position()
		stream_player.stop()

func _on_audio_stream_player_3d_finished() -> void:
	is_playing = false
	playback_pos = 0.0
