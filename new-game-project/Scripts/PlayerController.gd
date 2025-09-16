# PlayerController.gd
# 玩家角色八方向移動控制器
class_name PlayerController
extends CharacterBody2D

# 移動參數
@export var move_speed: float = 200.0

# 玩家角色圖片設定 - 可在編輯器中修改
@export_group("Player Sprite Settings")
@export var player_sprite_path: String = "res://Images/players/lumen_sorcerer/basic_attack.png"
@export var use_animated_sprite: bool = false
@export var animation_frame_count: int = 4
@export var sprite_folder_path: String = "res://Images/players/lumen_sorcerer/"
@export var sprite_name_prefix: String = "basic_attack"
@export var sprite_extension: String = ".png"

# 射擊參數
@export_group("Shooting Settings")
@export var shoot_cooldown: float = 0.3
@export var bullet_scene_path: String = "res://Scenes/MagicBullet.tscn"
var can_shoot: bool = true
var shoot_timer: float = 0.0

# 節點引用
@onready var collision_shape = $CollisionShape2D
@onready var sprite_2d = $Sprite2D

# 八方向輸入映射
var direction_map = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up_left": Vector2.UP + Vector2.LEFT,
	"up_right": Vector2.UP + Vector2.RIGHT,
	"down_left": Vector2.DOWN + Vector2.LEFT,
	"down_right": Vector2.DOWN + Vector2.RIGHT
}

func _ready():
	# 初始化設定
	print("玩家控制器已準備就緒")
	# 載入玩家角色圖片
	load_player_sprite()

func _physics_process(delta):
	# 處理移動輸入
	handle_movement(delta)
	# 處理射擊冷卻
	handle_shooting(delta)

func get_input_direction() -> Vector2:
	"""獲取輸入方向向量"""
	var input_vector = Vector2.ZERO
	
	# 方法一：使用預設輸入動作（方向鍵）
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	
	# 方法二：直接檢測 WASD 鍵盤按鍵
	if Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	if Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	
	# 正規化向量，確保對角線移動速度一致
	return input_vector.normalized()

func handle_movement(delta: float):
	"""處理玩家移動邏輯"""
	# 獲取輸入方向
	var direction = get_input_direction()
	
	# 設定速度
	if direction != Vector2.ZERO:
		velocity = direction * move_speed
	else:
		# 沒有輸入時停止移動
		velocity = Vector2.ZERO
	
	# 使用 move_and_slide() 進行移動
	move_and_slide()

func _input(event):
	"""處理其他輸入事件"""
	# 處理射擊輸入（滑鼠左鍵或空白鍵）
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			shoot()
	elif event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed:
			shoot()

func handle_shooting(delta: float):
	"""處理射擊冷卻計時"""
	if not can_shoot:
		shoot_timer += delta
		if shoot_timer >= shoot_cooldown:
			can_shoot = true
			shoot_timer = 0.0

func shoot():
	"""發射魔法彈"""
	if not can_shoot:
		return
	
	# 設定冷卻
	can_shoot = false
	shoot_timer = 0.0
	
	# 創建子彈實例
	var bullet_scene = load(bullet_scene_path) as PackedScene
	if not bullet_scene:
		print("錯誤：無法載入子彈場景：", bullet_scene_path)
		return
	
	# 創建子彈實例
	var bullet = bullet_scene.instantiate() as MagicBullet
	if not bullet:
		print("錯誤：無法創建子彈實例")
		return
	
	# 計算發射位置（CollisionShape2D 右側中點）
	var spawn_position = get_bullet_spawn_position()
	
	# 將子彈添加到場景樹中
	get_tree().current_scene.add_child(bullet)
	
	# 設定子彈位置和方向
	bullet.global_position = spawn_position
	bullet.set_direction(Vector2.RIGHT)  # 統一向右發射
	
	print("發射魔法彈於位置：", spawn_position)

func get_bullet_spawn_position() -> Vector2:
	"""計算子彈發射位置"""
	if not collision_shape or not collision_shape.shape:
		return global_position + Vector2(30, 0)  # 備用位置
	
	# 獲取碰撞形狀的大小
	var shape = collision_shape.shape
	var shape_size = Vector2.ZERO
	
	if shape is RectangleShape2D:
		shape_size = shape.size
	elif shape is CapsuleShape2D:
		shape_size = Vector2(shape.radius * 2, shape.height)
	elif shape is CircleShape2D:
		shape_size = Vector2(shape.radius * 2, shape.radius * 2)
	
	# 計算右側中點
	var offset = Vector2(shape_size.x * 0.5, 0)
	return global_position + offset

func load_player_sprite():
	"""載入玩家角色圖片"""
	if not sprite_2d:
		print("警告：找不到 Sprite2D 節點")
		return
	
	if not use_animated_sprite:
		# 使用單一圖片
		load_single_sprite()
	else:
		# 使用動畫序列（未來可擴展為行走動畫）
		load_animated_sprites()

func load_single_sprite():
	"""載入單一角色圖片"""
	var texture = load(player_sprite_path) as Texture2D
	if texture:
		sprite_2d.texture = texture
		print("成功載入角色圖片：", player_sprite_path)
	else:
		print("錯誤：無法載入角色圖片：", player_sprite_path)

func load_animated_sprites():
	"""載入動畫序列圖片（為未來擴展預留）"""
	# 目前只載入第一幀作為靜態圖片
	var first_frame_path = sprite_folder_path + sprite_name_prefix + "1" + sprite_extension
	var texture = load(first_frame_path) as Texture2D
	if texture:
		sprite_2d.texture = texture
		print("載入動畫角色第一幀：", first_frame_path)
	else:
		print("錯誤：無法載入動畫角色圖片：", first_frame_path)
		# 嘗試載入備用圖片
		load_single_sprite()

func change_player_sprite(new_sprite_path: String):
	"""運行時更換角色圖片"""
	player_sprite_path = new_sprite_path
	load_single_sprite()

func change_player_animated_sprites(folder: String, prefix: String, extension: String, frame_count: int):
	"""運行時更換動畫角色資源"""
	sprite_folder_path = folder
	sprite_name_prefix = prefix
	sprite_extension = extension
	animation_frame_count = frame_count
	use_animated_sprite = true
	load_animated_sprites()
