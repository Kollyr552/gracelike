extends Node3D

signal door_opened

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var has_opened: bool = false

func _on_interactible_box_action_triggered() -> void:
	if not has_opened:
		door_opened.emit()
		animation_player.play("open")
		has_opened = true
