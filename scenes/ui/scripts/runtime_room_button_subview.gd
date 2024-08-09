extends VBoxContainer
class_name RuntimeRoomButtonSubview

@onready var room_button: Button = %Button
@onready var view: RoomIcon = %View

@export var id: int = -1
@export var path: String :
    set(value):
        path = value
        if is_inside_tree():
            view.object_path = load(path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    room_button.text = name
    print("ROOM: %s loads %s" % [name, path])
    view.object_path = load(path)


func attach_button_signal(cb: Callable):
    var room_dict = {
        "id": id,
        "name": name,
        "path": path,
    }

    var res: int = room_button.button_down.connect(cb.bind(room_dict))
    if res != OK:
        print("Unable to connect button signal from %s (code: %d)" % [name, res])
