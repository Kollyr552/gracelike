class_name Room extends Node3D

signal exit_door_opened

@onready var marker_startpoint: Marker3D = %MarkerStartpoint
@onready var marker_endpoint: Marker3D = %MarkerEndpoint

@export var spawn_weight: float = 10.0:
	set(val):
		spawn_weight = max(0.0, val)

func _ready() -> void:
	marker_startpoint.visible = true
	marker_endpoint.visible = true

func get_endpoint_position() -> Vector3:
	return marker_endpoint.global_position

func get_endpoint_rotation() -> float:
	return marker_endpoint.global_rotation.y

func set_room_startpoint_position(pos: Vector3) -> void:
	var s_pos = marker_startpoint.position
	global_position = Vector3(pos.x - s_pos.x, pos.y - s_pos.y, pos.z - s_pos.z)

func set_room_startpoint_rotation(rot_y: float) -> void:
	var s_rot_y = marker_startpoint.rotation.y
	global_rotation.y = rot_y - s_rot_y

func _on_exit_door_door_opened() -> void:
	exit_door_opened.emit()
