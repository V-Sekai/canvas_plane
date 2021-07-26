@tool
extends EditorPlugin

var editor_interface = null

func _init():
	print("Initialising CanvasPlane plugin")


func _notification(p_notification: int):
	match p_notification:
		NOTIFICATION_PREDELETE:
			print("Destroying CanvasPlane plugin")


func _get_plugin_name():
	return "CanvasPlane"
