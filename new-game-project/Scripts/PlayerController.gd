# PlayerController.gd
# 玩家角色八方向移動控制器
class_name PlayerController
extends CharacterBody2D

# 移動參數
@export var move_speed: float = 200.0

# 動畫系統
@export_group("Player Animation System")
@export var sprite_folder_path: String = "res://Images/players/lumen_sorcerer/"
@export var sprite_extension: String = ".png"
@export var animation_speed: float = 0.15  # 每幀持續時間（秒）

# 動畫狀態枚舉
enum AnimationState {
	IDLE,           # 待機
	START_MOVING,   # 開始移動
	WALKING,        # 連續移動
	STOP_MOVING,    # 停止移動
	CASTING         # 施法攻擊
}

# 射擊參數
@export_group("Shooting Settings")
@export var shoot_cooldown: float = 0.3
@export var bullet_scene_path: String = "res://Scenes/MagicBullet.tscn"
var can_shoot: bool = true
var shoot_timer: float = 0.0
var is_casting: bool = false
var casting_attack_fired: bool = false
var continuous_attack: bool = false

# 動畫系統變數
var current_state: AnimationState = AnimationState.IDLE
var animation_timer: float = 0.0
var current_frame: int = 0
var animation_textures: Dictionary = {}

# 移動控制變數
var movement_input: Vector2 = Vector2.ZERO
var current_movement_input: Vector2 = Vector2.ZERO
var can_move: bool = true
var movement_locked: bool = false

# 輸入檢測
var attack_input_pressed: bool = false
var attack_input_held: bool = false

# 節點引用
@onready var collision_shape = $CollisionShape2D
@onready var sprite_2d = $Sprite2D

func _ready():
	print("玩家控制器已準備就緒")
	
	# 設定玩家碰撞層：第1層是玩家層
	collision_layer = 1
	collision_mask = 1  # 玩家可以與其他玩家/物體碰撞
	
	load_animation_textures()
	change_animation_state(AnimationState.IDLE)

func load_animation_textures():
	"""載入所有動畫材質"""
	animation_textures.clear()
	
	var texture_list = [
		"stand",
		"start_end_step1", 
		"start_end_step2",
		"step1",
		"step2", 
		"step3",
		"basic_attack1",
		"basic_attack2"
	]
	
	for texture_name in texture_list:
		var path = sprite_folder_path + texture_name + sprite_extension
		var texture = load(path) as Texture2D
		if texture:
			animation_textures[texture_name] = texture
			print("成功載入材質：", path)
		else:
			print("警告：無法載入材質：", path)
	
	print("總共載入了 ", animation_textures.size(), " 個動畫材質")

func _physics_process(delta):
	# 更新動畫計時器
	animation_timer += delta
	handle_shooting(delta)
	
	# 獲取輸入但不立即應用移動
	movement_input = get_input_direction()
	
	# 處理動畫狀態和移動邏輯
	handle_animation_and_movement()
	
	# 應用移動（只有在允許移動時）
	if can_move and not movement_locked:
		apply_movement()

func get_input_direction() -> Vector2:
	"""獲取輸入方向向量"""
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	
	return input_vector.normalized()

func apply_movement():
	"""應用實際移動"""
	if current_movement_input != Vector2.ZERO:
		velocity = current_movement_input * move_speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func handle_animation_and_movement():
	"""處理動畫狀態轉換和移動控制"""
	if not animation_finished():
		return
	
	match current_state:
		AnimationState.IDLE:
			set_sprite_texture("stand")
			
			# 檢查是否有攻擊輸入
			if attack_input_pressed:
				start_attack()
			# 檢查是否有移動輸入
			elif movement_input != Vector2.ZERO:
				change_animation_state(AnimationState.START_MOVING)
		
		AnimationState.START_MOVING:
			if current_frame == 0:
				set_sprite_texture("start_end_step1")
				current_frame = 1
				reset_animation_timer()
			elif current_frame == 1:
				set_sprite_texture("start_end_step2")
				# 完成start_end_step2後開始允許移動
				current_movement_input = movement_input
				
				# 檢查下一步動作
				if movement_input != Vector2.ZERO:
					change_animation_state(AnimationState.WALKING)
				else:
					change_animation_state(AnimationState.STOP_MOVING)
		
		AnimationState.WALKING:
			# 允許移動
			current_movement_input = movement_input
			
			# 檢查攻擊輸入（優先級最高）
			if attack_input_pressed:
				change_animation_state(AnimationState.STOP_MOVING)
				return
			
			# 檢查是否停止移動
			if movement_input == Vector2.ZERO:
				change_animation_state(AnimationState.STOP_MOVING)
				return
			
			# 循環播放行走動畫
			var step_textures = ["step1", "step2", "step3"]
			var step_index = current_frame % step_textures.size()
			set_sprite_texture(step_textures[step_index])
			current_frame += 1
			reset_animation_timer()
		
		AnimationState.STOP_MOVING:
			# 停止移動
			current_movement_input = Vector2.ZERO
			
			if current_frame == 0:
				set_sprite_texture("start_end_step2")
				current_frame = 1
				reset_animation_timer()
			elif current_frame == 1:
				set_sprite_texture("start_end_step1")
				
				# 檢查下一步動作
				if attack_input_pressed:
					change_animation_state(AnimationState.IDLE)  # 會在下一幀觸發攻擊
				else:
					change_animation_state(AnimationState.IDLE)
		
		AnimationState.CASTING:
			handle_casting_animation()

func handle_casting_animation():
	"""處理施法動畫"""
	# 禁止移動
	current_movement_input = Vector2.ZERO
	movement_locked = true
	
	if current_frame == 0:
		set_sprite_texture("basic_attack1")
		
		# 在basic_attack1時發射魔法彈
		if not casting_attack_fired:
			fire_bullet()
			casting_attack_fired = true
		
		current_frame = 1
		reset_animation_timer()
		
	elif current_frame == 1:
		set_sprite_texture("basic_attack2")
		
		# 檢查是否連續攻擊
		if continuous_attack and attack_input_held:
			# 重置為下一輪攻擊
			current_frame = 0
			casting_attack_fired = false
			reset_animation_timer()
		else:
			# 攻擊結束，解除鎖定
			movement_locked = false
			is_casting = false
			change_animation_state(AnimationState.IDLE)

func start_attack():
	"""開始攻擊"""
	if not can_shoot:
		return
	
	# 設定冷卻
	can_shoot = false
	shoot_timer = 0.0
	is_casting = true
	casting_attack_fired = false
	
	# 檢查是否為連續攻擊
	continuous_attack = attack_input_held
	
	change_animation_state(AnimationState.CASTING)

func change_animation_state(new_state: AnimationState):
	"""改變動畫狀態"""
	if current_state != new_state:
		current_state = new_state
		current_frame = 0
		reset_animation_timer()
		print("動畫狀態改變為：", AnimationState.keys()[new_state])

func set_sprite_texture(texture_name: String):
	"""設定精靈材質"""
	if texture_name in animation_textures:
		sprite_2d.texture = animation_textures[texture_name]
		print("切換到圖片：", texture_name)
	else:
		print("警告：找不到材質：", texture_name)

func animation_finished() -> bool:
	"""檢查當前動畫幀是否完成"""
	return animation_timer >= animation_speed

func reset_animation_timer():
	"""重設動畫計時器"""
	animation_timer = 0.0

func handle_shooting(delta: float):
	"""處理射擊冷卻計時"""
	if not can_shoot:
		shoot_timer += delta
		if shoot_timer >= shoot_cooldown:
			can_shoot = true
			shoot_timer = 0.0

func _input(event):
	"""處理輸入事件"""
	# 處理攻擊輸入
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				attack_input_pressed = true
				attack_input_held = true
			else:
				attack_input_held = false
	elif event is InputEventKey:
		if event.keycode == KEY_SPACE:
			if event.pressed:
				attack_input_pressed = true
				attack_input_held = true
			else:
				attack_input_held = false

func _process(_delta):
	"""每幀重置攻擊輸入標記"""
	attack_input_pressed = false

func fire_bullet():
	"""發射魔法彈"""
	print("準備發射魔法彈...")
	
	# 動態載入子彈場景
	var bullet_scene = load(bullet_scene_path) as PackedScene
	if not bullet_scene:
		print("錯誤：無法載入子彈場景：", bullet_scene_path)
		return
	
	# 創建子彈實例
	var bullet = bullet_scene.instantiate() as MagicBullet
	if not bullet:
		print("錯誤：無法創建子彈實例")
		return
	
	# 計算發射位置
	var spawn_position = get_bullet_spawn_position()
	
	# 將子彈添加到場景樹中
	get_tree().current_scene.add_child(bullet)
	
	# 設定子彈位置、方向和發射者
	bullet.global_position = spawn_position
	bullet.set_direction(Vector2.RIGHT)
	bullet.set_shooter(self)  # 設定發射者為玩家本身
	
	print("發射魔法彈於位置：", spawn_position)

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
