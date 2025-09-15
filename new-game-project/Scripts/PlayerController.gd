# PlayerController.gd
# 玩家角色八方向移動控制器
class_name PlayerController
extends CharacterBody2D

# 移動參數
@export var move_speed: float = 200.0

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

func _physics_process(delta):
	# 處理移動輸入
	handle_movement(delta)

func get_input_direction() -> Vector2:
	"""獲取輸入方向向量"""
	var input_vector = Vector2.ZERO
	
	# 使用自定義輸入動作
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
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
	# 這裡可以加入其他控制，如技能施放等
	pass
