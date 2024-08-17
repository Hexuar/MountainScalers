extends Node2D

@export_multiline var text : Array[String]

@onready var SpeechBubble = $SpeechBubble
@onready var UIBot = get_parent().get_parent().get_node("UI/Minibot")
@onready var Vignette = get_parent().get_parent().get_node("UI/Vignette")

var Player : CharacterBody2D
var textPosition = 0
var speed : float

signal minibot_done

func _process(delta: float) -> void:
	position.y += speed * delta
	if Input.is_action_just_pressed("ui_accept") and SpeechBubble.visible:
		if textPosition >= text.size():
			Player.resume()
			UIBot.visible = false
			SpeechBubble.visible = false
			speed = -60.0
			Vignette.material.set_shader_parameter("softness",1.5)
			emit_signal("minibot_done")
			return
		if textPosition == 0:
			Player.pause()
			UIBot.visible = true
			Vignette.material.set_shader_parameter("softness",1.0)
		UIBot.get_node("Speech Bubble/Text").text = "[color=\"black\"]%s[/color]" % text[textPosition]
		textPosition += 1


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		Player = body
		body.canJump = false
		SpeechBubble.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.canJump = true
		SpeechBubble.visible = false
