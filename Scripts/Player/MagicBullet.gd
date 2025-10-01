# MagicBullet.gd
# 簡化版魔法彈腳本
class_name MagicBullet
extends Area2D

# 子彈參數
@export var speed: float = 500.0
@export var max_distance: float = 800.0
@export var damage: int = 50

# 材質路徑設定
@export var texture_folder_path: String = "res://Images/sorcerer_attack/basic_attack/"
@export var texture_name_prefix: String = "Arcane_Effect_"
@export var texture_extension: String = ".png"

# 固定碰撞半徑
@export var collision_radius: float = 15.0

# 視覺縮放設定
@export_group("Visual Scaling")
@export var use_sprite_scaling: bool = true
@export var initial_scale: float = 0.8
@export var final_scale: float = 1.5

# 動畫相關
var bullet_textures: Array[Texture2D] = []
var current_frame: int = 0
var max_frames: int = 7

# 移動相關
var direction: Vector2 = Vector2.RIGHT
var traveled_distance: float = 0.0

# 發射者追蹤 - 避免自我碰撞
var shooter: Node = null

# 節點引用
var sprite: Sprite2D
var collision_shape: CollisionShape2D

func _ready():
	print("MagicBullet _ready() 被調用")
	
	# 設定碰撞層：子彈只與敵人碰撞，不與玩家碰撞
	collision_layer = 0  # 子彈不在任何碰撞層
	collision_mask = 2   # 子彈只檢測第2層（敵人層）
	
	# 設定節點結構
	setup_nodes()
	
	# 載入子彈材質
	load_bullet_textures()
	
	# 設定初始材質和縮放
	if bullet_textures.size() > 0:
		sprite.texture = bullet_textures[0]
		if use_sprite_scaling:
			sprite.scale = Vector2(initial_scale, initial_scale)
		print("✅ 子彈初始化完成")
	else:
		print("❌ 沒有載入任何子彈材質")

func setup_nodes():
	"""設定子彈的節點結構"""
	# 創建 Sprite2D
	sprite = Sprite2D.new()
	add_child(sprite)
	
	# 創建 CollisionShape2D
	collision_shape = CollisionShape2D.new()
	add_child(collision_shape)
	
	# 設定固定的圓形碰撞形狀
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = collision_radius
	collision_shape.shape = circle_shape
	
	# 連接碰撞信號
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func load_bullet_textures():
	"""載入所有子彈材質"""
	bullet_textures.clear()
	
	for i in range(1, max_frames + 1):  # 1 到 7
		var texture_path = texture_folder_path + texture_name_prefix + str(i) + texture_extension
		var texture = load(texture_path) as Texture2D
		if texture:
			bullet_textures.append(texture)
			print("成功載入子彈材質：", texture_path)
		else:
			print("警告：無法載入子彈材質 ", texture_path)
	
	print("總共載入了 ", bullet_textures.size(), " 個子彈材質")

func _physics_process(delta):
	# 移動子彈
	var velocity = direction * speed * delta
	position += velocity
	traveled_distance += velocity.length()
	
	# 更新子彈外觀
	update_bullet_appearance()
	
	# 檢查是否超出最大距離
	if traveled_distance >= max_distance:
		print("子彈達到最大距離，銷毀")
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
	
	# 更新視覺縮放
	if use_sprite_scaling:
		var current_scale = lerp(initial_scale, final_scale, progress)
		sprite.scale = Vector2(current_scale, current_scale)

func set_direction(new_direction: Vector2):
	"""設定子彈飛行方向"""
	direction = new_direction.normalized()
	print("子彈方向設定為：", direction)

func set_shooter(shooter_node: Node):
	"""設定發射者，避免自我碰撞"""
	shooter = shooter_node
	print("子彈發射者設定為：", shooter_node.name if shooter_node else "null")

func _on_body_entered(body):
	"""碰撞到物體時的處理"""
	print("子彈撞到 Body：", body.name, " 類型：", body.get_class())
	
	# 檢查是否是發射者本身
	if body == shooter:
		print("忽略發射者碰撞：", body.name)
		return
	
	# 正常的碰撞處理
	if body.has_method("take_damage"):
		body.take_damage(damage)
		print("對 ", body.name, " 造成 ", damage, " 傷害")
	
	destroy_bullet()

func _on_area_entered(area):
	print("子彈撞到 Area：", area.name, " 類型：", area.get_class())
	
	# 檢查是否是發射者本身
	if area == shooter:
		print("忽略發射者區域碰撞：", area.name)
		return
	
	# 檢查是否有 take_damage 方法（是敵人）
	if area.has_method("take_damage"):
		area.take_damage(damage)
		print("對 ", area.name, " 造成 ", damage, " 點傷害")
	
	destroy_bullet()

func destroy_bullet():
	"""銷毀子彈"""
	print("銷毀子彈")
	queue_free()
