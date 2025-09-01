class_name DebugPanel extends PanelContainer

@export var property_container: VBoxContainer

func _ready() -> void:
	visible = false
	
	Global.debug_panel = self

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_openpanel"):
		visible = !visible

func update_property(title: String, value, list_order: int=0):
	var property
	property = property_container.find_child(title, false, false)
	if not property:
		property = Label.new()
		property_container.add_child(property)
		property.name = title
	elif visible: #+if property
		property.text = title + ": " + str(value)
		property_container.move_child(property, list_order)
