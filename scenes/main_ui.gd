extends Control

@onready var multiplay=$".."


func _on_client_pressed() -> void:
	multiplay.start_client()


func _on_server_pressed() -> void:
	multiplay.start_server()
