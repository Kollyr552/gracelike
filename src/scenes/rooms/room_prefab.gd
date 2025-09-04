class_name Room extends Node3D

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

func get_endpoint_rotation() -> Vector3:
	return marker_endpoint.global_rotation
