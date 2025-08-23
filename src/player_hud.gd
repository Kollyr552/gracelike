extends CanvasLayer

@onready var h_speed_label: Label = %HSpeedLabel
@onready var v_speed_label: Label = %VSpeedLabel

func set_speed_labels(vel: Vector3) -> void:
	v_speed_label.text = ("Vertical: %s" % vel.y)
	h_speed_label.text = ("Horizontal: %s" % Vector2(vel.x, vel.z).length())
