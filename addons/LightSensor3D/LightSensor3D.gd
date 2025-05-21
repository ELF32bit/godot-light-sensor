@tool
@icon("LightSensor3D.svg")
class_name LightSensor3D
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

var _sub_viewport: SubViewport = null
var _remote_transform: RemoteTransform3D = null
var _mesh_instance: MeshInstance3D = null
var _camera: Camera3D = null
var _node: Node3D = null


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
				reading = image.get_pixel(0, 0) * sqrt(2.1) # magic number
				reading = reading.clamp(Color.BLACK, Color.WHITE)
				reading_updated.emit(reading)


func _on_visibility_changed() -> void:
	if is_instance_valid(_sub_viewport):
		@warning_ignore("int_as_enum_without_cast")
		_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS * int(visible)
	set_process(visible and not Engine.is_editor_hint())


func _enter_tree() -> void:
	if not is_instance_valid(_sub_viewport):
		_sub_viewport = SubViewport.new()
		_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_sub_viewport.positional_shadow_atlas_size = 256
		_sub_viewport.gui_disable_input = true
		_sub_viewport.size = Vector2i(32, 32)
		self.add_child(_sub_viewport, true)
		_sub_viewport.owner = self

	if not is_instance_valid(_node):
		_node = Node3D.new()
		_sub_viewport.add_child(_node, true)
		_node.owner = self

	if not is_instance_valid(_mesh_instance):
		_mesh_instance = MeshInstance3D.new()
		_mesh_instance.mesh = preload("LightSensor3D.obj")
		_mesh_instance.set_surface_override_material(0, preload("LightSensor3D.tres"))
		_mesh_instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		_mesh_instance.ignore_occlusion_culling = true
		_mesh_instance.cast_shadow = 0
		_node.add_child(_mesh_instance, true)
		_mesh_instance.owner = self

	if not is_instance_valid(_camera):
		_camera = Camera3D.new()
		_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		_camera.rotation_degrees = Vector3(-90.0, 45.0, 0.0)
		_camera.position = Vector3(0.0, 0.55, 0.0)
		_camera.size = sqrt(2.0) / 2.0
		_node.add_child(_camera, true)
		_camera.owner = self

	if not is_instance_valid(_remote_transform):
		_remote_transform = RemoteTransform3D.new()
		_remote_transform.update_scale = false
		self.add_child(_remote_transform, true)
		_remote_transform.owner = self

	_remote_transform.remote_path = _remote_transform.get_path_to(_node)
