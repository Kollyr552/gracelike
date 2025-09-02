class_name InteractBox extends Area3D

signal on_input_press

func _ready() -> void:
	for c in get_children(false):
		if c is CollisionShape3D or c is CollisionPolygon3D:
			c.debug_color = Color.GREEN_YELLOW

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		on_input_press.emit()
