@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("LightSensor3D", "Node3D", preload("LightSensor3D.gd"), preload("LightSensor3D.svg"))


func _exit_tree() -> void:
	remove_custom_type("LightSensor3D")
