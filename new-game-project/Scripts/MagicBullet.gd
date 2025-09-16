# MagicBullet.gd
# 魔法彈腳本，具有飛行距離變大效果
class_name MagicBullet
extends Area2D

# 子彈參數
@export var speed: float = 500.0
@export var max_distance: float = 800.0
@export var damage: int = 50

# 材質路徑設定 - 可在編輯器中修改
@export var texture_folder_path: String = "res://Images/sorcerer_attack/basic_attack/"
@export var texture_name_prefix: String = "Arcane_Effect_"
@export var texture_extension: String = ".png"

# 碰撞形狀縮放設定
@export var collision_scale_factor: float = 0.4  # 碰撞半徑相對於圖片大小的比例
@export var use_auto_collision_size: bool = true  # 是否自動根據圖片大小計算碰撞
@export var manual_initial_radius: float = 10.0   # 手動設定的初始半徑
@export var manual_final_radius: float = 25.0     # 手動設定的最終半徑

# 實際使用的碰撞半徑（會根據圖片自動計算）
var actual_initial_radius: float = 10.0
var actual_final_radius: float = 25.0

# 動畫相關
var bullet_textures: Array[Texture2D] = []
var current_frame: int = 0
var max_frames: int = 7

# 移動相關
var direction: Vector2 = Vector2.RIGHT
var traveled_distance: float = 0.0
var start_position: Vector2

# 節點引用
var sprite: Sprite2D
var collision_shape: CollisionShape2D

func _ready():
	# 設定節點結構
	setup_nodes()
	
	# 載入子彈材質
	load_bullet_textures()
	
	# 計算碰撞半徑
	calculate_collision_radii()
	
	# 記錄初始位置
	start_position = global_position
	
	# 設定初始材質和碰撞大小
	if bullet_textures.size() > 0:
		sprite.texture = bullet_textures[0]
		update_collision_size(0.0)  # 設定初始碰撞大小

func setup_nodes():
	"""設定子彈的節點結構"""
	# 創建 Sprite2D
	sprite = Sprite2D.new()
	add_child(sprite)
	
	# 創建 CollisionShape2D
	collision_shape = CollisionShape2D.new()
	add_child(collision_shape)
	
	# 設定圓形碰撞形狀（稍後會根據圖片大小調整）
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 10.0  # 臨時值，會被 calculate_collision_radii() 覆蓋
	collision_shape.shape = circle_shape
	
	# 連接碰撞信號
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func calculate_collision_radii():
	"""根據圖片大小計算碰撞半徑"""
	if not use_auto_collision_size:
		# 使用手動設定值
		actual_initial_radius = manual_initial_radius
		actual_final_radius = manual_final_radius
		print("使用手動碰撞半徑：", actual_initial_radius, " -> ", actual_final_radius)
		return
	
	# 自動計算基於圖片大小
	if bullet_textures.size() >= 2:
		var first_texture = bullet_textures[0]
		var last_texture = bullet_textures[-1]  # 最後一張圖片
		
		if first_texture and last_texture:
			# 計算圖片的最小邊作為直徑參考
			var first_size = min(first_texture.get_width(), first_texture.get_height())
			var last_size = min(last_texture.get_width(), last_texture.get_height())
			
			# 根據圖片大小和縮放因子計算碰撞半徑
			actual_initial_radius = (first_size * collision_scale_factor) / 2.0
			actual_final_radius = (last_size * collision_scale_factor) / 2.0
			
			print("根據圖片自動計算碰撞半徑：")
			print("  第一張圖片大小：", first_texture.get_size(), " -> 碰撞半徑：", actual_initial_radius)
			print("  最後一張圖片大小：", last_texture.get_size(), " -> 碰撞半徑：", actual_final_radius)
		else:
			print("警告：無法獲取圖片大小，使用預設值")
			actual_initial_radius = manual_initial_radius
			actual_final_radius = manual_final_radius
	else:
		print("警告：載入的圖片不足，使用預設碰撞半徑")
		actual_initial_radius = manual_initial_radius
		actual_final_radius = manual_final_radius

func load_bullet_textures():
	"""載入所有子彈材質"""
	bullet_textures.clear()
	
	for i in range(1, max_frames + 1):  # 1 到 max_frames
		var texture_path = texture_folder_path + texture_name_prefix + str(i) + texture_extension
		var texture = load(texture_path) as Texture2D
		if texture:
			bullet_textures.append(texture)
			print("成功載入材質：", texture_path)
		else:
			print("警告：無法載入材質 ", texture_path)
	
	print("總共載入了 ", bullet_textures.size(), " 個材質")
func _physics_process(delta):
	# 移動子彈
	var velocity = direction * speed * delta
	position += velocity
	traveled_distance += velocity.length()
	
	# 更新子彈外觀
	update_bullet_appearance()
	
	# 檢查是否超出最大距離
	if traveled_distance >= max_distance:
		destroy_bullet()

func update_bullet_appearance():
	"""根據飛行距離更新子彈外觀"""
	if bullet_textures.size() == 0:
		return
	
	# 計算飛行進度 (0.0 到 1.0)
	var progress = min(traveled_distance / max_distance, 1.0)
	
	# 計算應該使用哪一幀
	var target_frame = min(int(progress * max_frames), max_frames - 1)
	
	# 更新材質
	if target_frame != current_frame and target_frame < bullet_textures.size():
		current_frame = target_frame
		sprite.texture = bullet_textures[current_frame]
	
	# 更新碰撞形狀大小
	update_collision_size(progress)

func update_collision_size(progress: float):
	"""根據進度更新碰撞形狀大小"""
	if not collision_shape or not collision_shape.shape:
		return
	
	var shape = collision_shape.shape
	if shape is CircleShape2D:
		# 線性插值計算當前半徑
		var current_radius = lerp(actual_initial_radius, actual_final_radius, progress)
		shape.radius = current_radius
		
		# 調試輸出（可選，正式版本可以移除）
		#print("碰撞半徑更新為：", current_radius, " (進度：", progress, ")")
	
	# 如果你想看到碰撞形狀的變化，可以啟用調試模式
	# collision_shape.debug_color = Color.RED

func set_direction(new_direction: Vector2):
	"""設定子彈飛行方向"""
	direction = new_direction.normalized()

func _on_body_entered(body):
	"""碰撞到物體時的處理"""
	if body.has_method("take_damage"):
		body.take_damage(damage)
	destroy_bullet()

func _on_area_entered(area):
	"""碰撞到其他區域時的處理"""
	destroy_bullet()

func destroy_bullet():
	"""銷毀子彈"""
	queue_free()
