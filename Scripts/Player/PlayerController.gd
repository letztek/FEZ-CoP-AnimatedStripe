# PlayerController.gd
# FEZ: Chronicle of the Players - 動畫版玩家控制器
class_name PlayerController
extends CharacterBody2D

# 移動參數
@export var move_speed: float = 200.0

# 射擊參數
@export_group("Shooting Settings")
@export var shoot_cooldown: float = 0.3
@export var bullet_scene_path: String = "res://Scenes/Bullets/MagicBullet.tscn"

# 動畫狀態
enum AnimationState {
	IDLE,
	WALK_FORWARD,
	WALK_BACKWARD,
	ATTACKING
}

# 狀態變數
var current_state: AnimationState = AnimationState.IDLE
var is_attacking: bool = false
var can_shoot: bool = true
var shoot_timer: float = 0.0

# 節點引用
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
	print("動畫玩家控制器初始化完成")
	
	# 設定玩家碰撞層：第1層是玩家層
	collision_layer = 1
	collision_mask = 1
	
	# 檢查動畫資源
	if animated_sprite.sprite_frames:
		print("✅ SpriteFrames 載入成功")
		print("可用動畫: ", animated_sprite.sprite_frames.get_animation_names())
		
		# 開始播放 idle 動畫
		play_animation("idle_frames")
	else:
		print("❌ 沒有 SpriteFrames 資源！")

func _physics_process(delta):
	# 處理射擊冷卻
	handle_shooting_cooldown(delta)
	
	# 攻擊期間不能移動
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# 獲取移動輸入
	var movement = get_movement_input()
	
	# 調試移動輸入
	if movement != Vector2.ZERO:
		print("移動輸入: ", movement)
	
	# 根據輸入更新動畫
	update_animation_state(movement)
	
	# 應用移動
	var old_position = global_position
	velocity = movement * move_speed
	
	# 詳細調試信息
	if movement != Vector2.ZERO:
		print("設置前 velocity: ", velocity)
		print("移動前位置: ", old_position)
	
	move_and_slide()
	
	if movement != Vector2.ZERO:
		print("移動後位置: ", global_position)
		print("位置差: ", global_position - old_position)
		print("實際 velocity: ", velocity)
		print("---")

func get_movement_input() -> Vector2:
	"""獲取八方向移動輸入"""
	var input = Vector2.ZERO
	
	# 直接獲取各方向輸入
	if Input.is_action_pressed("move_forward"):   # D
		input.x += 1
	if Input.is_action_pressed("move_backward"):  # A
		input.x -= 1
	if Input.is_action_pressed("move_up"):        # W
		input.y -= 1
	if Input.is_action_pressed("move_down"):      # S
		input.y += 1
	
	# 調試輸入檢測
	if input != Vector2.ZERO:
		print("實際移動輸入: ", input)
	
	return input.normalized()

func update_animation_state(movement: Vector2):
	"""根據移動狀態更新動畫"""
	var new_state: AnimationState
	
	if movement == Vector2.ZERO:
		new_state = AnimationState.IDLE
	# 動畫優先級：如果有向後移動分量，就播放後退動畫
	elif movement.x < 0:  # 包含向後移動
		new_state = AnimationState.WALK_BACKWARD
	elif movement.x > 0 or movement.y != 0:  # 向前移動或純垂直移動
		new_state = AnimationState.WALK_FORWARD
	else:
		new_state = AnimationState.IDLE
	
	# 只有狀態改變時才切換動畫
	if new_state != current_state:
		current_state = new_state
		play_current_state_animation()

func play_current_state_animation():
	"""播放當前狀態對應的動畫"""
	match current_state:
		AnimationState.IDLE:
			play_animation("idle_frames")
		AnimationState.WALK_FORWARD:
			play_animation("walk_forward_frames")
		AnimationState.WALK_BACKWARD:
			play_animation("walk_backward_frames")
		AnimationState.ATTACKING:
			play_animation("basic_attack_frames")

func play_animation(animation_name: String):
	"""安全地播放動畫"""
	if not animated_sprite or not animated_sprite.sprite_frames:
		print("❌ AnimatedSprite2D 或 SpriteFrames 不存在")
		return
	
	if animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.animation = animation_name
		animated_sprite.play()
		print("播放動畫: ", animation_name)
	else:
		print("⚠️ 動畫不存在: ", animation_name)
		print("可用動畫: ", animated_sprite.sprite_frames.get_animation_names())

func _input(event):
	"""處理攻擊輸入"""
	if event.is_action_pressed("attack") and can_shoot and not is_attacking:
		print("攻擊按鍵被按下")
		start_attack()

func start_attack():
	"""開始攻擊"""
	is_attacking = true
	can_shoot = false
	shoot_timer = 0.0
	current_state = AnimationState.ATTACKING
	play_animation("basic_attack_frames")
	
	# 發射子彈
	fire_bullet()
	
	# 設置攻擊結束計時器
	var attack_duration = 0.6
	get_tree().create_timer(attack_duration).timeout.connect(end_attack)
	
	print("⚔️ 開始攻擊")

func end_attack():
	"""結束攻擊"""
	is_attacking = false
	print("✅ 攻擊結束")
	
	# 回到 idle 狀態
	current_state = AnimationState.IDLE
	play_animation("idle_frames")

func fire_bullet():
	"""發射魔法彈"""
	print("fire_bullet() 被調用")
	print("bullet_scene_path: ", bullet_scene_path)
	
	# 動態載入子彈場景
	var bullet_scene = load(bullet_scene_path) as PackedScene
	if not bullet_scene:
		print("錯誤：無法載入子彈場景：", bullet_scene_path)
		return
	
	print("✅ 子彈場景載入成功")
	
	# 創建子彈實例
	var bullet = bullet_scene.instantiate()
	if not bullet:
		print("錯誤：無法創建子彈實例")
		return
	
	print("✅ 子彈實例創建成功")
	
	# 計算發射位置
	var spawn_position = get_bullet_spawn_position()
	
	# 將子彈添加到場景樹中
	get_tree().current_scene.add_child(bullet)
	
	# 設定子彈位置、方向和發射者
	bullet.global_position = spawn_position
	bullet.set_direction(Vector2.RIGHT)
	bullet.set_shooter(self)
	
	print("🚀 發射魔法彈於位置：", spawn_position)

func get_bullet_spawn_position() -> Vector2:
	"""計算子彈發射位置"""
	if not collision_shape or not collision_shape.shape:
		return global_position + Vector2(30, 0)
	
	var shape = collision_shape.shape
	var shape_size = Vector2.ZERO
	
	if shape is RectangleShape2D:
		shape_size = shape.size
	elif shape is CapsuleShape2D:
		shape_size = Vector2(shape.radius * 2, shape.height)
	elif shape is CircleShape2D:
		shape_size = Vector2(shape.radius * 2, shape.radius * 2)
	
	var offset = Vector2(shape_size.x * 0.5, 0)
	return global_position + offset

func handle_shooting_cooldown(delta: float):
	"""處理射擊冷卻"""
	if not can_shoot:
		shoot_timer += delta
		if shoot_timer >= shoot_cooldown:
			can_shoot = true
