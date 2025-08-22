@icon("res://assets/steamhappy.png")
extends CharacterBody3D

enum Action{
	WALK,
	SPRINT,
	CROUCH,
	SLIDE,
}
var action: Action = Action.WALK

@export_category("Movement")
@export var max_speed: float = 6.0
@export var acceleration: float = 30.0
@export var friction: float = 20.0
@export var slide_friction: float = 10.0

@export var jump_velocity: float = 3.5

@export var mouse_sensitivity: float = 2.0


@onready var head: Marker3D = %HeadPos
@onready var spring_arm_3d: SpringArm3D = $SpringArm3D

@onready var tall_collision: CollisionShape3D = $TallCollision


func _input(event: InputEvent) -> void:
	## Switch nouse capture
	if event.is_action_pressed("change_mouse_capture"):
		match Input.get_mouse_mode():
			Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	## Head motion
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_head(event.relative)

func _unhandled_input(event: InputEvent) -> void:
	## Capture mouse on click
	if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	## Quit game
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	var move_dir := set_move_direction()
	
	walk(move_dir, delta)
	
	gravity(delta)
	jump()
	
	move_and_slide()

func jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

func gravity(d_t :float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * d_t

func set_move_direction() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, head.rotation.y) ## Rotate with camera
	return direction

func walk(direction: Vector3, d_t: float) -> void:	
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	
	## Check acceleration direction
	var temp_accel: float
	if direction.dot(horizontal_velocity) > 0: 
		temp_accel = acceleration ## Same direction
	else: 
		temp_accel = friction     ## Different direction
		
	horizontal_velocity = horizontal_velocity.move_toward(direction * max_speed, temp_accel * d_t)
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

func rotate_head(mouse_axis : Vector2) -> void:
	## Horizontal mouse look
	head.rotation.y -= mouse_axis.x * (mouse_sensitivity/1000)
	head.rotation.y = wrapf(head.rotation.y, 0.0, TAU)
	
	## Vertical mouse look
	head.rotation.x -= mouse_axis.y * (mouse_sensitivity/1000)
	head.rotation.x = clamp(head.rotation.x, -PI*0.5, PI*0.35)
