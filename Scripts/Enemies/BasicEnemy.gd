# BasicEnemy.gd
class_name BasicEnemy
extends Area2D

@onready var sprite = $Sprite2D

func _init():
	print("========== BasicEnemy 腳本執行了 ==========")

func _ready():
	collision_layer = 2
	collision_mask = 0
	
	print("敵人已生成，位置：", global_position)
	if sprite:
		print("Sprite 存在，紋理：", sprite.texture)
	else:
		print("Sprite 節點不存在！")

func take_damage(amount: int):
	print("敵人受到 ", amount, " 點傷害")
	die()

func die():
	print("敵人死亡，調用來源：")
	print_stack()
	queue_free()
