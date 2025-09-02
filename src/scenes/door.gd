extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var has_opened: bool = false

func _on_interactible_box_action_triggered() -> void:
	if not has_opened:
		animation_player.play("open")
		has_opened = true
