extends CanvasLayer
class_name ModelMenu

signal delete_me

@onready var name_label: Label = $MarginContainer/VBoxContainer/Name
@export var device_name: String = "NAME":
    set(value):
        device_name = value
        name_label.text = value

func _ready() -> void:
    name_label.text = device_name


func _on_delete_button_pressed():
    delete_me.emit()
