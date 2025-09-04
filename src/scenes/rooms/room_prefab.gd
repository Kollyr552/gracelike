class_name Room extends Node3D

@onready var marker_startpoint: Marker3D = %MarkerStartpoint
@onready var marker_endpoint: Marker3D = %MarkerEndpoint

func get_endpoint_position() -> Vector3:
	return marker_endpoint.global_position
