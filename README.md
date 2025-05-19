# LightSensor3D plugin for Godot 4
![Demonstration](screenshots/demonstration.gif)

LightSensor3D plugin provides a way to sample environment lighting in 3D scenes.<br>
This can be useful for stealth games where the player can hide in the shadows.<br>
Another application might involve tinting 2D UI elements like FPS weapons.<br>

## Usage
* Drop **LightSensor3D.tscn** in your scene.
* Reserve render layer for the plugins gizmo.
* Disable gizmo render layer on the scene cameras.
* Adjust plugin configuration inside **LightSensor3D.gd**.