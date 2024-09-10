extends CharacterBody3D

@export var speed = 10.0
@export var mouse_sensitivity = 0.005
@export var camera_distance = 4.0
@export var camera_height = 2.0
@export var gravity = -9.8

# Переменная для отслеживания вращения камеры
var rotation_enabled = false
var camera_rotation = Vector2()  # Для хранения вращения камеры

# Переменная для направления движения
var move_direction = Vector3.ZERO

func _ready():
	# Включение слежения за курсором
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()

	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			# Включаем вращение камеры при нажатии ПКМ
			rotation_enabled = event.pressed

	if event is InputEventMouseMotion and rotation_enabled:
		# Вращаем камеру вокруг игрока
		camera_rotation.x -= event.relative.x * mouse_sensitivity
		camera_rotation.y = clamp(camera_rotation.y - event.relative.y * mouse_sensitivity, -45, 20)

func _physics_process(delta: float) -> void:
	# Сброс направления движения
	move_direction = Vector3.ZERO

	# Определяем направление камеры
	var camera_forward = -$CameraPivot/Camera3D.global_transform.basis.z.normalized()
	var camera_right = $CameraPivot/Camera3D.global_transform.basis.x.normalized()

	# Проверяем нажатия клавиш и задаем направление движения в локальных координатах камеры
	if Input.is_action_pressed("move_forward"):
		move_direction += camera_forward
	if Input.is_action_pressed("move_backward"):
		move_direction -= camera_forward
	if Input.is_action_pressed("move_left"):
		move_direction -= camera_right
	if Input.is_action_pressed("move_right"):
		move_direction += camera_right

	# Нормализуем вектор движения для сохранения скорости при диагональном движении
	move_direction = move_direction.normalized()

	# Применяем гравитацию
	velocity.y += gravity * delta
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed

	# Перемещаем игрока с учетом гравитации и столкновений
	move_and_slide()

	_update_camera()

func _update_camera():
	# Позиция камеры относительно игрока
	var camera_position = Vector3(0, camera_height, camera_distance)
	
	# Вращение камеры вокруг игрока по осям X и Y
	camera_position = camera_position.rotated(Vector3(1, 0, 0), camera_rotation.y)
	camera_position = camera_position.rotated(Vector3(0, 1, 0), camera_rotation.x)
	
	# Устанавливаем новую позицию камеры относительно игрока
	$CameraPivot/Camera3D.global_transform.origin = global_transform.origin + camera_position
	
	# Направляем камеру, чтобы она смотрела на игрока
	$CameraPivot/Camera3D.look_at(global_transform.origin, Vector3.UP)

func _rotate_character_to_camera():
	# Определяем направление, в котором должна смотреть модель персонажа
	var character_forward = -$CameraPivot/Camera3D.global_transform.basis.z.normalized()
	# Поворачиваем персонажа, чтобы он смотрел в том же направлении
	look_at(global_transform.origin + character_forward, Vector3.UP)
