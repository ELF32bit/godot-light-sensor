@tool
@icon("LightSensor3D.svg")
extends Node3D

# turn off this layer on cameras to hide gizmo
const RENDER_LAYER: int = 10

signal reading_updated(reading: Color)

var reading := Color.WHITE

@export var radius: float = 0.5:
	set(value):
		value = clampf(value, 0.001, INF)
		if is_instance_valid(mesh_instance):
			mesh_instance.scale = Vector3.ONE * value * 2.0
		if is_instance_valid(camera):
			camera.position.y = value + camera.near
			camera.size = value * sqrt(2.0)
			camera.far = clampf(camera.far, 2.0 * (value + camera.near), INF)
		radius = value

@onready var sub_viewport: SubViewport = $"SubViewport"
@onready var mesh_instance: MeshInstance3D = $"SubViewport/Node3D/MeshInstance3D"
@onready var camera: Camera3D = $"SubViewport/Node3D/Camera3D"


func _ready() -> void:
	mesh_instance.set_layer_mask_value(RENDER_LAYER, true)
	radius = radius # updating dependant nodes
	_on_visibility_changed() # updating subviewport update mode

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	var viewport_texture := sub_viewport.get_texture()
	if not viewport_texture:
		return
	var image := viewport_texture.get_image()
	if not image:
		return
	image.resize(1, 1, Image.INTERPOLATE_LANCZOS)
	reading = image.get_pixel(0, 0) * sqrt(2.1) # magic number
	reading = reading.clamp(Color.BLACK, Color.WHITE)
	reading_updated.emit(reading)


func _on_visibility_changed() -> void:
	@warning_ignore("int_as_enum_without_cast")
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS * int(visible)
	set_process(visible and not Engine.is_editor_hint())
