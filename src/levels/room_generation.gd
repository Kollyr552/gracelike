extends Node3D

@onready var rooms_node: Node3D = $Rooms

@export var starting_room: Room

var current_room: Room
var next_room: Room

func _ready() -> void:
	current_room = starting_room
	current_room.exit_door_opened.connect(spawn_next_room)

func spawn_next_room() -> void:
	current_room.exit_door_opened.disconnect(spawn_next_room)
	next_room = get_next_room_scene().instantiate()
	
	rooms_node.add_child(next_room)
	
	next_room.set_room_startpoint_position(current_room.get_endpoint_position())
	next_room.set_room_startpoint_rotation(current_room.get_endpoint_rotation())
	
	current_room = next_room
	next_room.exit_door_opened.connect(spawn_next_room)

func get_next_room_scene() -> PackedScene:
	## Get random room
	var max_rooms = Data.room_types.size()
	var room_id = Global.rng.randi_range(0, max_rooms-1)
	
	return Data.room_types[room_id]
