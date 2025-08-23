class_name CameraBob
extends Node3D

@export var bob_speed: float = 15.0
@export var bob_height: float = 0.05
@export var bob_ease: float = 1.0

var target_bob_ypos: float = 0.0

func bob_view(time:float, do_bob:bool, d_t:float) -> void:
	
	if do_bob:
		target_bob_ypos = (cos(time*bob_speed) - 1.0) * bob_height
	else:
		target_bob_ypos = 0.0
	
	position.y = move_toward(position.y, target_bob_ypos, bob_ease*d_t)
