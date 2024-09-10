class_name main_camera extends Camera3D

@export var target: Node3D
@export var lerp_speed: float

func _process(delta: float) -> void:
	global_position = target.global_position
	
