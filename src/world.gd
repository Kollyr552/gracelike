extends Node3D

@export var debug_fps_cap: int = 60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.set_max_fps(debug_fps_cap)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
