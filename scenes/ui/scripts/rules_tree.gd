extends Control

var tree: Tree = null
var room_status: Dictionary = {}
var device_status: Dictionary = {}

func device_name(device: TreeItem, room: TreeItem) -> String:
    return "%s-%s" % [room.get_text(0), device.get_text(0)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    tree = Tree.new()
    tree.custom_minimum_size = Vector2(750, 575)
    tree.scale = Vector2(2, 2)
    tree.columns = 2
    var root: TreeItem = tree.create_item()
    tree.hide_root = true

    for room in Globals.get_rooms():
        var room_node: TreeItem = tree.create_item(root)
        room_node.set_text(0, (room["name"] as String))
        room_node.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
        room_node.set_editable(1, true)
        room_node.set_meta("data", room)
        room_status[room["name"]] = false  # Not selected by default

        for device in Globals.get_devices_in_room((room["id"] as int)):
            print("%d - %s" % [room["id"], device["name"]])
            var device_node: TreeItem = tree.create_item(room_node)
            device_node.set_meta("data", device)
            device_node.set_text(0, (device["name"] as String))
            device_node.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
            device_node.set_editable(1, true)
            device_status[device_name(device_node, room_node)] = false

    add_child(tree)


func _process(_delta: float):
    for room in tree.get_root().get_children():
        if room.is_checked(1) and not room_status[room.get_text(0)]:  # Just got checked
            Globals.spawn_room.emit(room.get_meta("data"))
            for device in room.get_children():
                Globals.show_rules_from.emit(device.get_meta("data")["id"])
                device.set_checked(1, true)

        elif not room.is_checked(1) and room_status[room.get_text(0)]:  # Just got unchecked
            Globals.delete_room.emit(room.get_meta("data")["id"])
            for device in room.get_children():
                Globals.hide_rules_from.emit(device.get_meta("data")["id"])
                device.set_checked(1, false)

        else:  # Check if there's been a change in the children
            var room_still_checked = false  # `or` with all children statuses

            for device in room.get_children():
                if device.is_checked(1) and not device_status[device_name(device, room)]:  # Just got checked
                    Globals.show_rules_from.emit(device.get_meta("data")["id"])
                elif not device.is_checked(1) and device_status[device_name(device, room)]:  # Just got unchecked
                    Globals.hide_rules_from.emit(device.get_meta("data")["id"])

                device_status[device_name(device, room)] = device.is_checked(1)
                room_still_checked = room_still_checked or device.is_checked(1)

            if not room_still_checked:  # If all children are deselected, deselect the room
                if room.is_checked(1):
                    Globals.delete_room.emit(room.get_meta("data")["id"])
                room.set_checked(1, false)
                room_status[room.get_text(0)] = false
            else:  # Room is checked as long as it has at least a single child selected
                if !room.is_checked(1):
                    Globals.spawn_room.emit(room.get_meta("data"))
                room.set_checked(1, true)
                room_status[room.get_text(0)] = true

        room_status[room.get_text(0)] = room.is_checked(1)
