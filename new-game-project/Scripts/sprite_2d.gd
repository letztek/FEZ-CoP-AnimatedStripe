# PlayerController.gd
# 八方向移動系統
extends CharacterBody2D

# 移動速度
var move_speed = 200.0

func _physics_process(delta):
	# 獲取輸入方向
	var direction = Vector2.ZERO
	
	# 檢查八方向輸入
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	
	# 正規化對角線移動（保持相同速度）
	direction = direction.normalized()
	
	# 設置速度
	velocity = direction * move_speed
	
	# 執行移動
	move_and_slide()
