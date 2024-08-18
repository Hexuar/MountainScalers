extends Node2D

@onready var Player = $Player
@export var levelScale : float = 1.0

func _ready() -> void:
	scale = Vector2(levelScale,levelScale)
	Player.scale = Vector2(1/levelScale,1/levelScale)
