@tool
@icon("LightSensor3D.svg")
extends Node3D

@export var radius: float = 0.5:
	set(value):
		value = clampf(value, 0.001, INF)
		if is_instance_valid(_mesh_instance):
			_mesh_instance.scale = Vector3.ONE * value * 2.0
		if is_instance_valid(_camera):
			_camera.position.y = value + _camera.near
			_camera.size = value * sqrt(2.0)
			_camera.far = clampf(_camera.far, 2.0 * (value + _camera.near), INF)
		radius = value

@export_flags_3d_render var render_layers: int = 512:
	set(value):
		if is_instance_valid(_mesh_instance):
			_mesh_instance.layers = value
		render_layers = value

var reading := Color.WHITE
signal reading_updated(reading: Color)

@onready var _sub_viewport: SubViewport = $"SubViewport"
@onready var _mesh_instance: MeshInstance3D = $"SubViewport/Node3D/MeshInstance3D"
@onready var _camera: Camera3D = $"SubViewport/Node3D/Camera3D"


func _ready() -> void:
	_on_visibility_changed() # updating subviewport update mode
	render_layers = render_layers # updating mesh instance layers
	radius = radius # updating dependant nodes

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if is_instance_valid(_sub_viewport):
		var viewport_texture := _sub_viewport.get_texture()
		if viewport_texture:
			var image := viewport_texture.get_image()
			if image:
				image.resize(1, 1, Image.INTERPOLATE_LANCZOS)
				reading = image.get_pixel(0, 0) * 1.449 # magic number
				reading = reading.clamp(Color.BLACK, Color.WHITE)
				reading_updated.emit(reading)


func _on_visibility_changed() -> void:
	if is_instance_valid(_sub_viewport):
		_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_sub_viewport.render_target_update_mode *= int(visible)
		set_process(visible and not Engine.is_editor_hint())
