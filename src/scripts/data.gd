class_name Data extends Node

static var room_types: Array[PackedScene] = [
	preload("res://src/scenes/rooms/room_straight.tscn"),
	preload("res://src/scenes/rooms/room_turn_left.tscn"),
	preload("res://src/scenes/rooms/room_turn_right.tscn"),
]

static func _static_init() -> void:
	room_types.make_read_only()
