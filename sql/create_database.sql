
DROP TABLE IF EXISTS link;
DROP TABLE IF EXISTS device_instance;
DROP TABLE IF EXISTS device_instance_property;
DROP TABLE IF EXISTS device_property;
DROP TABLE IF EXISTS device;
DROP TABLE IF EXISTS room;


CREATE TABLE IF NOT EXISTS room (
	id INTEGER PRIMARY KEY NOT NULL,
	name char(255),
	path char(255)
);

-- All existing devices
CREATE TABLE IF NOT EXISTS device (
	id INTEGER PRIMARY KEY NOT NULL,
	name char(255),
	path char(255)
);

-- Property value types (colorwheel multiple choice, ...)
CREATE TABLE IF NOT EXISTS property_value_type (
	id INTEGER PRIMARY KEY NOT NULL,
	type char(255)
);

-- Properties of the devices (e.g. TV on/off, resolutions, lamp color)
CREATE TABLE IF NOT EXISTS device_property (
	id INTEGER PRIMARY KEY NOT NULL,
	name char(255),
	device_id INTEGER,
	property_type_id INTEGER,
	FOREIGN KEY (device_id) REFERENCES device(id),
	FOREIGN KEY (property_type_id) REFERENCES property_value_type(id)
);

-- All the instances of the devices
CREATE TABLE IF NOT EXISTS device_instance(
	id INTEGER PRIMARY KEY NOT NULL,
	room_id INTEGER,
	device_id INTEGER,
	FOREIGN KEY (room_id) REFERENCES room(id) ON DELETE CASCADE,
	FOREIGN KEY (device_id) REFERENCES device(id) ON DELETE CASCADE
);

-- All the properties of the instanciated devices
CREATE TABLE IF NOT EXISTS device_instance_property(
	id INTEGER PRIMARY KEY NOT NULL,
	device_id INTEGER,
	property_id INTEGER,
	value char(255),
	FOREIGN KEY (device_id) REFERENCES device_instance(id) ON DELETE CASCADE,
	FOREIGN KEY (property_id) REFERENCES device_property(id) ON DELETE CASCADE
);

-- Rule links between devices
CREATE TABLE IF NOT EXISTS link(
	id INTEGER PRIMARY KEY NOT NULL,
	from_device_id INTEGER NOT NULL,       -- What device to watch
	from_device_property_id INTEGER,       -- What property to watch
	from_device_property_value char(255),  -- What property value triggers the rule
	to_device_id INTEGER NOT NULL,      -- What device to change
	to_device_property_id INTEGER,      -- What property to change on the device
	to_device_property_value char(255), -- What value to set this property
	FOREIGN KEY (from_device_id) REFERENCES device_instance(id) ON DELETE CASCADE,
	FOREIGN KEY (from_device_property_id) REFERENCES device_instance_property(id) ON DELETE CASCADE,
	FOREIGN KEY (to_device_id) REFERENCES device_instance(id) ON DELETE CASCADE,
	FOREIGN KEY (to_device_property_id) REFERENCES device_instance_property(id) ON DELETE CASCADE
);


INSERT INTO room(name, path) VALUES
("living room", "res://scenes/rooms/living_room.tscn"),
("bedroom", "res://scenes/rooms/bed_room.tscn"),
("garage", "res://scenes/rooms/garage.tscn"),
("kitchen", "res://scenes/rooms/kitchen.tscn"),
("office", "res://scenes/rooms/office.tscn");


-- These are the existing devices, not the ones in the hand menu
INSERT INTO device(name, path) VALUES
("television", "res://assets/devices/television/TV.glb"),
("lamp", "res://assets/devices/lamp/lamp.glb"),
("ceiling light", "res://assets/devices/ceiling_light/ceilingLamp.glb"),
("reading light", "res://assets/devices/reading_light/reading_light.glb"),
("bed", "res://assets/models/bed/Bed.glb"),
("dresser", "res://assets/models/dresser/Dresser.glb"),
("sofa", "res://assets/models/sofa/sofa.glb"),
("table", "res://assets/models/table/table.glb");

INSERT INTO property_value_type(type) VALUES
("colorwheel"),
("toggle"),
("spinbox"),
("multichoice");


INSERT INTO device_property(name, device_id, property_type_id) VALUES
("power status", 1, 2),  -- 1) Television on/off  -- toggle
("volume", 1, 3),        -- 2) Television volume  -- spinbox
("channel", 1, 3),       -- 3) Television channel  -- spinbox
("input", 1, 4),         -- 4) Television input (HDMI/...)  -- Multichoice
("power status", 2, 2),  -- 5) lamp on/off
("color", 2, 1),         -- 6) Lamp color (rgb)
("power status", 3, 2),  -- 7) Ceiling light on/off
("color", 3, 1),         -- 8) Ceiling light color (rgb)
("power status", 4, 2),  -- 9) Reading light on/off
("color", 4, 1),         -- 10) Reading light color (rgb)
("power status", 5, 2),  -- 11) Bed on/off ?????
("power status", 6, 2),  -- 12) dresser on/off ?????
("power status", 7, 2),  -- 13) sofa on/off ?????
("power status", 8, 2);  -- 14) table on/off ?????


INSERT INTO device_instance(room_id, device_id) VALUES
(1, 1),  -- 1) Television in living room
(1, 2),  -- 2) Lamp in living room
(1, 7),  -- 3) Sofa in living room
(1, 8),  -- 4) Table in living room
(2, 4),  -- 5) Reading light in bedroom
(2, 5),  -- 6) Bed in bedroom
(2, 6),  -- 7) Dresser in bedroom
(3, 3),  -- 8) Ceiling Light in garage
(5, 2),  -- 9) Lamp in office
(5, 4);  -- 10) Reading light in office


INSERT INTO device_instance_property(device_id, property_id, value) VALUES
-- Television in living room
(1, 1, "on"),      -- power on
(1, 2, "50"),      -- volume 50
(1, 3, "1"),       -- channel 1
(1, 4, "HDMI 1"),  -- input HDMI 1
-- Lamp in living room
(2, 5, "off"),      -- Lamp is off (tv is on)
(2, 6, "#ffffff"),  -- Color white (but lamp off so meh)
-- Sofa in living room
(3, 13, "on"),  -- Sofa on for relaxation ?????
-- Table in living room
(4, 14, "on"),  -- The table is on,... really...
-- Reading light in bedroom
(5, 9, "on"),        -- power on
(5, 10, "#ff0000"),  -- red, why not
-- Bed in bedroom
(6, 11, "on"),  -- The bed is on for maximum confort
-- Dresser in bedroom
(7, 12, "off"),  -- /shrug
-- Ceiling light in garage
(8, 7, "off"),      -- Light off, no one in the garage
(8, 8, "#000000"),  -- Someone pulled a prank, even when turned on, the light will be off
-- Lamp in office
(9, 5, "on"),       -- Someone's working
(9, 6, "#ff00ff"),  -- idk
-- Reading light in office
(10, 9, "on"),        -- power on
(10, 10, "#dddddd");  -- white

INSERT INTO link(from_device_id, from_device_property_id, from_device_property_value, to_device_id, to_device_property_id, to_device_property_value) VALUES
-- Inside Living room
(1, 1, "on", 2, 5, "off"),   -- Television on means lamp off
(1, 1, "on", 3, 13, "on"),   -- Television on means sofa on (maximu relaxation)
(6, 11, "on", 5, 9, "off"),  -- When bed on, reading light off
(10, 9, "on", 8, 7, "off");  -- Someone in the office ? Turn off the garage (why not)