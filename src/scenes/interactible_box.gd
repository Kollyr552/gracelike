class_name InteractibleBox extends Area3D

signal action_triggered

## Decides whether the action requires a seperate interaction input to be triggered
@export var requires_input: bool = false

func _ready() -> void:
	for c in get_children(false):
		if c is CollisionShape3D or c is CollisionPolygon3D:
			c.debug_color = Color.GREEN_YELLOW

func _on_area_entered(interact_box: Area3D) -> void:
	if interact_box is InteractBox:
		if requires_input:
			interact_box.on_input_press.connect(trigger_with_required_input.bind(interact_box))
		else:
			action_triggered.emit()

func _on_area_exited(interact_box: Area3D) -> void:
	if interact_box is InteractBox:
		interact_box.on_input_press.disconnect(trigger_with_required_input)

func trigger_with_required_input(ibox: InteractBox) -> void:
	action_triggered.emit()
