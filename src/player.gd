@icon("res://assets/steamhappy.png")
extends CharacterBody3D

enum Action{
	WALK,
	RUN,
	CROUCH,
	SLIDE,
}
var action: Action = Action.WALK

var is_input_crouch: bool = false

@export_category("Movement")
@export var max_speed: float = 6.0
@export var run_speed: float = 12.0
@export var crouch_speed_mult: float = 0.5
@export var acceleration: float = 40.0
@export var friction: float = 60.0
@export_range(0.0, 1.0) var slide_friction: float = 0.25
@export_range(0.0, 1.0) var slide_turn_speed: float = 0.7

@export var jump_velocity: float = 3.5
@export var gravity_mult: float = 1.0

@export_category("Camera")
@export var mouse_sensitivity: float = 2.0
@export var crouch_camera_height: float = 0.0
@export var default_camera_height: float = 1.5
@export var camera_crouch_speed: float = 5.0
var desired_camera_height: float

@onready var head: Marker3D = %HeadPos
@onready var spring_arm_3d: SpringArm3D = $SpringArm3D
@onready var view_bob: CameraBob = $SpringArm3D/HeadPos/ViewBob

@onready var tall_collision: CollisionShape3D = $TallCollision
@onready var crouch_collision: CollisionShape3D = $CrouchCollision
@onready var ceiling_check: RayCast3D = $CeilingCheck

func _input(event: InputEvent) -> void:
	## Switch mouse capture
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

func _ready() -> void:
	tall_collision.disabled = false
	crouch_collision.disabled = true
	spring_arm_3d.spring_length = default_camera_height
	desired_camera_height = default_camera_height

func _physics_process(delta: float) -> void:
	var move_dir := set_move_direction()
	
	## State machine
	match action:
		Action.WALK:
			fsm_walk(move_dir, delta)
		Action.RUN:
			fsm_run(move_dir, delta)
		Action.CROUCH:
			fsm_crouch(move_dir, delta)
		Action.SLIDE:
			fsm_slide(move_dir, delta)
	
	#print_debug("state: ", action)
	
	gravity(delta)
	jump()
	
	bob(delta)
	ease_camera_height(delta)
	
	move_and_slide()
	
	Global.debug_panel.update_property("Horizontal Velocity", "%.3f" % get_horizontal_velocity().length(), 1)
	Global.debug_panel.update_property("Vertical Velocity", "%.3f" % velocity.y, 2)
	Global.debug_panel.update_property("Action", Action.keys()[action], 3)

func _process(delta: float) -> void:
	
	is_input_crouch = Input.is_action_pressed("move_crouch")
	
	toggle_crouch_collision(is_input_crouch, delta)

func jump() -> void:
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = jump_velocity

func gravity(d_t :float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_mult * d_t

func set_move_direction() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, head.rotation.y) ## Rotate with camera
	return direction

func get_horizontal_velocity() -> Vector3:
	return Vector3(velocity.x, 0.0, velocity.z)

func fsm_walk(direction: Vector3, d_t: float) -> void:
	## Check acceleration direction
	var temp_accel: float
	if direction.dot(get_horizontal_velocity()) > 0: 
		temp_accel = acceleration ## Same direction
	else: 
		temp_accel = friction     ## Different direction
		
	var temp_vel := get_horizontal_velocity().move_toward(direction * max_speed, temp_accel * d_t)
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z
	
	if Input.is_action_just_pressed("move_run"):
		action = Action.RUN
	
	if Input.is_action_just_pressed("move_crouch"):
		action = Action.CROUCH

func fsm_run(direction: Vector3, d_t: float) -> void:
	
	## Check acceleration direction
	var temp_accel: float
	if direction.dot(get_horizontal_velocity()) > 0: 
		temp_accel = acceleration ## Same direction
	else: 
		temp_accel = friction     ## Different direction
		
	var temp_vel := get_horizontal_velocity().move_toward(direction * run_speed, temp_accel * d_t)
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z
	
	if Input.is_action_just_released("move_run"):
		action = Action.WALK
	
	if Input.is_action_just_pressed("move_crouch"):
		action = Action.SLIDE

func fsm_crouch(direction: Vector3, d_t: float) -> void:
	## Check acceleration direction
	var temp_accel: float
	if direction.dot(get_horizontal_velocity()) > 0: 
		temp_accel = acceleration ## Same direction
	else: 
		temp_accel = friction     ## Different direction
		
	var temp_vel := get_horizontal_velocity().move_toward(direction * max_speed * crouch_speed_mult, temp_accel * d_t)
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z
	
	if Input.is_action_just_released("move_crouch"):
		if Input.is_action_pressed("move_run"):
			action = Action.RUN
		else:
			action = Action.WALK
			

func fsm_slide(direction: Vector3, d_t: float) -> void:
	
	var h_vel: Vector3= get_horizontal_velocity()
	
	## Get slope (slide) angle - sliding across a slope is like sliding on a flat surface
	var surface_normal := get_floor_normal()
	var slope_boost = cos( h_vel.angle_to(surface_normal) )
	print("angle: ",rad_to_deg(h_vel.angle_to(surface_normal)), " | cos: ", cos( h_vel.angle_to(surface_normal) ))
	
	## Rotation
	if direction.x != 0.0 and direction.z != 0.0:
		h_vel = h_vel.slerp(direction*h_vel.length(), 1 - pow(1-slide_turn_speed, d_t))
		
	## Friction
	surface_normal.y = 0.0
	h_vel = h_vel.lerp(surface_normal*max_speed*10, 1 - pow(1-slide_friction,d_t))
	
	velocity.x = h_vel.x
	velocity.z = h_vel.z
	
	
	if Input.is_action_just_released("move_crouch"):
		if Input.is_action_pressed("move_run"):
			action = Action.RUN
		else:
			action = Action.WALK

func rotate_head(mouse_axis : Vector2) -> void:
	## Horizontal mouse look
	head.rotation.y -= mouse_axis.x * (mouse_sensitivity/1000)
	head.rotation.y = wrapf(head.rotation.y, 0.0, TAU)
	
	## Vertical mouse look
	head.rotation.x -= mouse_axis.y * (mouse_sensitivity/1000)
	head.rotation.x = clamp(head.rotation.x, -PI*0.5, PI*0.35)

func toggle_crouch_collision(toggle: bool, d_t: float) -> void:
	if toggle: ## toggle on
		tall_collision.disabled = true
		crouch_collision.disabled = false
		desired_camera_height = crouch_camera_height
	elif not ceiling_check.is_colliding(): ## toggle off AND no ceiling
		tall_collision.disabled = false
		crouch_collision.disabled = true
	if not toggle:
		desired_camera_height = default_camera_height

func ease_camera_height(d_t: float):
	## Camera movement
		spring_arm_3d.spring_length = move_toward(spring_arm_3d.spring_length, desired_camera_height, camera_crouch_speed*d_t)

func bob(d_t:float):
	if action == Action.SLIDE: return
	var btime: float = Engine.get_physics_frames() / (Engine.physics_ticks_per_second as float)
	var bob_check: bool = Vector3(velocity.x, 0.0, velocity.z).length_squared() >= 2.5
	view_bob.bob_view(btime, bob_check, d_t)
