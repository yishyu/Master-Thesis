extends CanvasLayer
class_name RoomMenu

signal hide
signal delete
signal save

@onready var room_label: Label = %RoomName
@export var room_name: String = "Name":
    set(value):
        room_name = value
        if is_inside_tree():
            room_label.text = value


func _ready() -> void:
    room_label.text = room_name


func _on_hide_button_pressed() -> void:
    hide.emit()

func _on_delete_button_pressed() -> void:
    delete.emit()

func _on_save_button_pressed() -> void:
    save.emit()
