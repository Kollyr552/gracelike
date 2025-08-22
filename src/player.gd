extends CharacterBody3D


@export var max_speed: float = 300.0
@export var friction: float = 50.0
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
	
	move(delta)
	
	gravity(delta)
	jump()
	
	move_and_slide()
	
	#head.position = spring_arm_3d.position

func jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

func gravity(d_t :float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * d_t

func move(d_t: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, head.rotation.y)
	
	if direction:
		velocity.x = direction.x * max_speed * d_t
		velocity.z = direction.z * max_speed * d_t
	else:
		velocity.x = move_toward(velocity.x, 0, friction * d_t)
		velocity.z = move_toward(velocity.z, 0, friction * d_t)

func rotate_head(mouse_axis : Vector2) -> void:
	## Horizontal mouse look
	head.rotation.y -= mouse_axis.x * (mouse_sensitivity/1000)
	head.rotation.y = wrapf(head.rotation.y, 0.0, TAU)
	
	## Vertical mouse look
	head.rotation.x -= mouse_axis.y * (mouse_sensitivity/1000)
	head.rotation.x = clamp(head.rotation.x, -PI*0.5, PI*0.35)
