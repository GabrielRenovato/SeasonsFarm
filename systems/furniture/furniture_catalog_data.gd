extends Node

var data: Dictionary = {
	"chair_1": {
		"name": "Chair 1",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(0, 0, 16, 32), Rect2(48, 0, 16, 32), Rect2(16, 0, 16, 32), Rect2(32, 0, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_2": {
		"name": "Chair 2",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(64, 0, 16, 32), Rect2(112, 0, 16, 32), Rect2(80, 0, 16, 32), Rect2(96, 0, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_3": {
		"name": "Chair 3",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(128, 0, 16, 32), Rect2(176, 0, 16, 32), Rect2(144, 0, 16, 32), Rect2(160, 0, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_4": {
		"name": "Chair 4",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(192, 0, 16, 32), Rect2(240, 0, 16, 32), Rect2(208, 0, 16, 32), Rect2(224, 0, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_5": {
		"name": "Chair 5",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(0, 32, 16, 32), Rect2(48, 32, 16, 32), Rect2(16, 32, 16, 32), Rect2(32, 32, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_6": {
		"name": "Chair 6",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(64, 32, 16, 32), Rect2(112, 32, 16, 32), Rect2(80, 32, 16, 32), Rect2(96, 32, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_7": {
		"name": "Chair 7",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(128, 32, 16, 32), Rect2(176, 32, 16, 32), Rect2(144, 32, 16, 32), Rect2(160, 32, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_8": {
		"name": "Chair 8",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(192, 32, 16, 32), Rect2(240, 32, 16, 32), Rect2(208, 32, 16, 32), Rect2(224, 32, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_9": {
		"name": "Chair 9",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(0, 64, 16, 32), Rect2(48, 64, 16, 32), Rect2(16, 64, 16, 32), Rect2(32, 64, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_10": {
		"name": "Chair 10",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(64, 64, 16, 32), Rect2(112, 64, 16, 32), Rect2(80, 64, 16, 32), Rect2(96, 64, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_11": {
		"name": "Chair 11",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(128, 64, 16, 32), Rect2(176, 64, 16, 32), Rect2(144, 64, 16, 32), Rect2(160, 64, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_12": {
		"name": "Chair 12",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(192, 64, 16, 32), Rect2(240, 64, 16, 32), Rect2(208, 64, 16, 32), Rect2(224, 64, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_13": {
		"name": "Chair 13",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(0, 96, 16, 32), Rect2(48, 96, 16, 32), Rect2(16, 96, 16, 32), Rect2(32, 96, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_14": {
		"name": "Chair 14",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(64, 96, 16, 32), Rect2(112, 96, 16, 32), Rect2(80, 96, 16, 32), Rect2(96, 96, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_15": {
		"name": "Chair 15",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(128, 96, 16, 32), Rect2(176, 96, 16, 32), Rect2(144, 96, 16, 32), Rect2(160, 96, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_16": {
		"name": "Chair 16",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(192, 96, 16, 32), Rect2(240, 96, 16, 32), Rect2(208, 96, 16, 32), Rect2(224, 96, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_17": {
		"name": "Chair 17",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(0, 128, 16, 32), Rect2(48, 128, 16, 32), Rect2(16, 128, 16, 32), Rect2(32, 128, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_18": {
		"name": "Chair 18",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(64, 128, 16, 32), Rect2(112, 128, 16, 32), Rect2(80, 128, 16, 32), Rect2(96, 128, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_19": {
		"name": "Chair 19",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(128, 128, 16, 32), Rect2(176, 128, 16, 32), Rect2(144, 128, 16, 32), Rect2(160, 128, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_20": {
		"name": "Chair 20",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(192, 128, 16, 32), Rect2(240, 128, 16, 32), Rect2(208, 128, 16, 32), Rect2(224, 128, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_21": {
		"name": "Chair 21",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(0, 160, 16, 32), Rect2(48, 160, 16, 32), Rect2(16, 160, 16, 32), Rect2(32, 160, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_22": {
		"name": "Chair 22",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(64, 160, 16, 32), Rect2(112, 160, 16, 32), Rect2(80, 160, 16, 32), Rect2(96, 160, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_23": {
		"name": "Chair 23",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(128, 160, 16, 32), Rect2(176, 160, 16, 32), Rect2(144, 160, 16, 32), Rect2(160, 160, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_24": {
		"name": "Chair 24",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(192, 160, 16, 32), Rect2(240, 160, 16, 32), Rect2(208, 160, 16, 32), Rect2(224, 160, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_25": {
		"name": "Chair 25",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(0, 192, 16, 32), Rect2(48, 192, 16, 32), Rect2(16, 192, 16, 32), Rect2(32, 192, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_26": {
		"name": "Chair 26",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(64, 192, 16, 32), Rect2(112, 192, 16, 32), Rect2(80, 192, 16, 32), Rect2(96, 192, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_27": {
		"name": "Chair 27",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(128, 192, 16, 32), Rect2(176, 192, 16, 32), Rect2(144, 192, 16, 32), Rect2(160, 192, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"chair_28": {
		"name": "Chair 28",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [Rect2(192, 192, 16, 32), Rect2(240, 192, 16, 32), Rect2(208, 192, 16, 32), Rect2(224, 192, 16, 32)],
		"collision_sizes": [Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)],
		"collision_offsets": [Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)]
	},
	"bed_single_1": {
		"name": "Single Bed 1",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(0, 0, 32, 48), Rect2(0, 0, 32, 48), Rect2(0, 0, 32, 48), Rect2(0, 0, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_2": {
		"name": "Single Bed 2",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(32, 0, 32, 48), Rect2(32, 0, 32, 48), Rect2(32, 0, 32, 48), Rect2(32, 0, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_3": {
		"name": "Single Bed 3",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(64, 0, 32, 48), Rect2(64, 0, 32, 48), Rect2(64, 0, 32, 48), Rect2(64, 0, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_4": {
		"name": "Single Bed 4",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(96, 0, 32, 48), Rect2(96, 0, 32, 48), Rect2(96, 0, 32, 48), Rect2(96, 0, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_5": {
		"name": "Single Bed 5",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(128, 0, 32, 48), Rect2(128, 0, 32, 48), Rect2(128, 0, 32, 48), Rect2(128, 0, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_6": {
		"name": "Single Bed 6",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(160, 0, 32, 48), Rect2(160, 0, 32, 48), Rect2(160, 0, 32, 48), Rect2(160, 0, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_7": {
		"name": "Single Bed 7",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(192, 0, 32, 48), Rect2(192, 0, 32, 48), Rect2(192, 0, 32, 48), Rect2(192, 0, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_8": {
		"name": "Single Bed 8",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(224, 0, 32, 48), Rect2(224, 0, 32, 48), Rect2(224, 0, 32, 48), Rect2(224, 0, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_9": {
		"name": "Single Bed 9",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(256, 0, 32, 48), Rect2(256, 0, 32, 48), Rect2(256, 0, 32, 48), Rect2(256, 0, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_10": {
		"name": "Single Bed 10",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(288, 0, 32, 48), Rect2(288, 0, 32, 48), Rect2(288, 0, 32, 48), Rect2(288, 0, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_11": {
		"name": "Single Bed 11",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(320, 0, 32, 48), Rect2(320, 0, 32, 48), Rect2(320, 0, 32, 48), Rect2(320, 0, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_12": {
		"name": "Single Bed 12",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(352, 0, 32, 48), Rect2(352, 0, 32, 48), Rect2(352, 0, 32, 48), Rect2(352, 0, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_13": {
		"name": "Single Bed 13",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(0, 48, 32, 48), Rect2(0, 48, 32, 48), Rect2(0, 48, 32, 48), Rect2(0, 48, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_14": {
		"name": "Single Bed 14",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(32, 48, 32, 48), Rect2(32, 48, 32, 48), Rect2(32, 48, 32, 48), Rect2(32, 48, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_15": {
		"name": "Single Bed 15",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(64, 48, 32, 48), Rect2(64, 48, 32, 48), Rect2(64, 48, 32, 48), Rect2(64, 48, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_16": {
		"name": "Single Bed 16",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(96, 48, 32, 48), Rect2(96, 48, 32, 48), Rect2(96, 48, 32, 48), Rect2(96, 48, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_17": {
		"name": "Single Bed 17",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(128, 48, 32, 48), Rect2(128, 48, 32, 48), Rect2(128, 48, 32, 48), Rect2(128, 48, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_18": {
		"name": "Single Bed 18",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(160, 48, 32, 48), Rect2(160, 48, 32, 48), Rect2(160, 48, 32, 48), Rect2(160, 48, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_19": {
		"name": "Single Bed 19",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(192, 48, 32, 48), Rect2(192, 48, 32, 48), Rect2(192, 48, 32, 48), Rect2(192, 48, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_20": {
		"name": "Single Bed 20",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(224, 48, 32, 48), Rect2(224, 48, 32, 48), Rect2(224, 48, 32, 48), Rect2(224, 48, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_21": {
		"name": "Single Bed 21",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(256, 48, 32, 48), Rect2(256, 48, 32, 48), Rect2(256, 48, 32, 48), Rect2(256, 48, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_22": {
		"name": "Single Bed 22",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(288, 48, 32, 48), Rect2(288, 48, 32, 48), Rect2(288, 48, 32, 48), Rect2(288, 48, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_23": {
		"name": "Single Bed 23",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(320, 48, 32, 48), Rect2(320, 48, 32, 48), Rect2(320, 48, 32, 48), Rect2(320, 48, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_24": {
		"name": "Single Bed 24",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(352, 48, 32, 48), Rect2(352, 48, 32, 48), Rect2(352, 48, 32, 48), Rect2(352, 48, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_25": {
		"name": "Single Bed 25",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(0, 96, 32, 48), Rect2(0, 96, 32, 48), Rect2(0, 96, 32, 48), Rect2(0, 96, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_26": {
		"name": "Single Bed 26",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(32, 96, 32, 48), Rect2(32, 96, 32, 48), Rect2(32, 96, 32, 48), Rect2(32, 96, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_27": {
		"name": "Single Bed 27",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(64, 96, 32, 48), Rect2(64, 96, 32, 48), Rect2(64, 96, 32, 48), Rect2(64, 96, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_28": {
		"name": "Single Bed 28",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(96, 96, 32, 48), Rect2(96, 96, 32, 48), Rect2(96, 96, 32, 48), Rect2(96, 96, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_29": {
		"name": "Single Bed 29",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(128, 96, 32, 48), Rect2(128, 96, 32, 48), Rect2(128, 96, 32, 48), Rect2(128, 96, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_30": {
		"name": "Single Bed 30",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(160, 96, 32, 48), Rect2(160, 96, 32, 48), Rect2(160, 96, 32, 48), Rect2(160, 96, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_31": {
		"name": "Single Bed 31",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(192, 96, 32, 48), Rect2(192, 96, 32, 48), Rect2(192, 96, 32, 48), Rect2(192, 96, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_32": {
		"name": "Single Bed 32",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(224, 96, 32, 48), Rect2(224, 96, 32, 48), Rect2(224, 96, 32, 48), Rect2(224, 96, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_33": {
		"name": "Single Bed 33",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(256, 96, 32, 48), Rect2(256, 96, 32, 48), Rect2(256, 96, 32, 48), Rect2(256, 96, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_34": {
		"name": "Single Bed 34",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(288, 96, 32, 48), Rect2(288, 96, 32, 48), Rect2(288, 96, 32, 48), Rect2(288, 96, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_35": {
		"name": "Single Bed 35",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(320, 96, 32, 48), Rect2(320, 96, 32, 48), Rect2(320, 96, 32, 48), Rect2(320, 96, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_single_36": {
		"name": "Single Bed 36",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(352, 96, 32, 48), Rect2(352, 96, 32, 48), Rect2(352, 96, 32, 48), Rect2(352, 96, 32, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_1": {
		"name": "Double Bed 1",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(0, 256, 48, 48), Rect2(0, 256, 48, 48), Rect2(0, 256, 48, 48), Rect2(0, 256, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_2": {
		"name": "Double Bed 2",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(48, 256, 48, 48), Rect2(48, 256, 48, 48), Rect2(48, 256, 48, 48), Rect2(48, 256, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_3": {
		"name": "Double Bed 3",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(96, 256, 48, 48), Rect2(96, 256, 48, 48), Rect2(96, 256, 48, 48), Rect2(96, 256, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_4": {
		"name": "Double Bed 4",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(144, 256, 48, 48), Rect2(144, 256, 48, 48), Rect2(144, 256, 48, 48), Rect2(144, 256, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_5": {
		"name": "Double Bed 5",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(192, 256, 48, 48), Rect2(192, 256, 48, 48), Rect2(192, 256, 48, 48), Rect2(192, 256, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_6": {
		"name": "Double Bed 6",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(240, 256, 48, 48), Rect2(240, 256, 48, 48), Rect2(240, 256, 48, 48), Rect2(240, 256, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_7": {
		"name": "Double Bed 7",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(288, 256, 48, 48), Rect2(288, 256, 48, 48), Rect2(288, 256, 48, 48), Rect2(288, 256, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_8": {
		"name": "Double Bed 8",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(336, 256, 48, 48), Rect2(336, 256, 48, 48), Rect2(336, 256, 48, 48), Rect2(336, 256, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_9": {
		"name": "Double Bed 9",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(0, 304, 48, 48), Rect2(0, 304, 48, 48), Rect2(0, 304, 48, 48), Rect2(0, 304, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_10": {
		"name": "Double Bed 10",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(48, 304, 48, 48), Rect2(48, 304, 48, 48), Rect2(48, 304, 48, 48), Rect2(48, 304, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_11": {
		"name": "Double Bed 11",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(96, 304, 48, 48), Rect2(96, 304, 48, 48), Rect2(96, 304, 48, 48), Rect2(96, 304, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_12": {
		"name": "Double Bed 12",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(144, 304, 48, 48), Rect2(144, 304, 48, 48), Rect2(144, 304, 48, 48), Rect2(144, 304, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_13": {
		"name": "Double Bed 13",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(192, 304, 48, 48), Rect2(192, 304, 48, 48), Rect2(192, 304, 48, 48), Rect2(192, 304, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_14": {
		"name": "Double Bed 14",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(240, 304, 48, 48), Rect2(240, 304, 48, 48), Rect2(240, 304, 48, 48), Rect2(240, 304, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_15": {
		"name": "Double Bed 15",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(288, 304, 48, 48), Rect2(288, 304, 48, 48), Rect2(288, 304, 48, 48), Rect2(288, 304, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_16": {
		"name": "Double Bed 16",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(336, 304, 48, 48), Rect2(336, 304, 48, 48), Rect2(336, 304, 48, 48), Rect2(336, 304, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_17": {
		"name": "Double Bed 17",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(0, 352, 48, 48), Rect2(0, 352, 48, 48), Rect2(0, 352, 48, 48), Rect2(0, 352, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_18": {
		"name": "Double Bed 18",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(48, 352, 48, 48), Rect2(48, 352, 48, 48), Rect2(48, 352, 48, 48), Rect2(48, 352, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_19": {
		"name": "Double Bed 19",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(96, 352, 48, 48), Rect2(96, 352, 48, 48), Rect2(96, 352, 48, 48), Rect2(96, 352, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_20": {
		"name": "Double Bed 20",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(144, 352, 48, 48), Rect2(144, 352, 48, 48), Rect2(144, 352, 48, 48), Rect2(144, 352, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_21": {
		"name": "Double Bed 21",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(192, 352, 48, 48), Rect2(192, 352, 48, 48), Rect2(192, 352, 48, 48), Rect2(192, 352, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_22": {
		"name": "Double Bed 22",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(240, 352, 48, 48), Rect2(240, 352, 48, 48), Rect2(240, 352, 48, 48), Rect2(240, 352, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_23": {
		"name": "Double Bed 23",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(288, 352, 48, 48), Rect2(288, 352, 48, 48), Rect2(288, 352, 48, 48), Rect2(288, 352, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"bed_double_24": {
		"name": "Double Bed 24",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [Rect2(336, 352, 48, 48), Rect2(336, 352, 48, 48), Rect2(336, 352, 48, 48), Rect2(336, 352, 48, 48)],
		"collision_sizes": [Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_1": {
		"name": "Desk 1",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(0, 0, 32, 32), Rect2(0, 0, 32, 32), Rect2(0, 0, 32, 32), Rect2(0, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_2": {
		"name": "Desk 2",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(32, 0, 32, 32), Rect2(32, 0, 32, 32), Rect2(32, 0, 32, 32), Rect2(32, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_3": {
		"name": "Desk 3",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(64, 0, 32, 32), Rect2(64, 0, 32, 32), Rect2(64, 0, 32, 32), Rect2(64, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_4": {
		"name": "Desk 4",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(96, 0, 32, 32), Rect2(96, 0, 32, 32), Rect2(96, 0, 32, 32), Rect2(96, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_5": {
		"name": "Desk 5",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(128, 0, 32, 32), Rect2(128, 0, 32, 32), Rect2(128, 0, 32, 32), Rect2(128, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_6": {
		"name": "Desk 6",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(160, 0, 32, 32), Rect2(160, 0, 32, 32), Rect2(160, 0, 32, 32), Rect2(160, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_7": {
		"name": "Desk 7",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(192, 0, 32, 32), Rect2(192, 0, 32, 32), Rect2(192, 0, 32, 32), Rect2(192, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_8": {
		"name": "Desk 8",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(224, 0, 32, 32), Rect2(224, 0, 32, 32), Rect2(224, 0, 32, 32), Rect2(224, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_9": {
		"name": "Desk 9",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(256, 0, 32, 32), Rect2(256, 0, 32, 32), Rect2(256, 0, 32, 32), Rect2(256, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_10": {
		"name": "Desk 10",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(288, 0, 32, 32), Rect2(288, 0, 32, 32), Rect2(288, 0, 32, 32), Rect2(288, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_11": {
		"name": "Desk 11",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(320, 0, 32, 32), Rect2(320, 0, 32, 32), Rect2(320, 0, 32, 32), Rect2(320, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_12": {
		"name": "Desk 12",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(352, 0, 32, 32), Rect2(352, 0, 32, 32), Rect2(352, 0, 32, 32), Rect2(352, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_13": {
		"name": "Desk 13",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(384, 0, 32, 32), Rect2(384, 0, 32, 32), Rect2(384, 0, 32, 32), Rect2(384, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_14": {
		"name": "Desk 14",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(416, 0, 32, 32), Rect2(416, 0, 32, 32), Rect2(416, 0, 32, 32), Rect2(416, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_15": {
		"name": "Desk 15",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(448, 0, 32, 32), Rect2(448, 0, 32, 32), Rect2(448, 0, 32, 32), Rect2(448, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_16": {
		"name": "Desk 16",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(480, 0, 32, 32), Rect2(480, 0, 32, 32), Rect2(480, 0, 32, 32), Rect2(480, 0, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_17": {
		"name": "Desk 17",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(0, 32, 32, 32), Rect2(0, 32, 32, 32), Rect2(0, 32, 32, 32), Rect2(0, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_18": {
		"name": "Desk 18",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(32, 32, 32, 32), Rect2(32, 32, 32, 32), Rect2(32, 32, 32, 32), Rect2(32, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_19": {
		"name": "Desk 19",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(64, 32, 32, 32), Rect2(64, 32, 32, 32), Rect2(64, 32, 32, 32), Rect2(64, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_20": {
		"name": "Desk 20",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(96, 32, 32, 32), Rect2(96, 32, 32, 32), Rect2(96, 32, 32, 32), Rect2(96, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_21": {
		"name": "Desk 21",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(128, 32, 32, 32), Rect2(128, 32, 32, 32), Rect2(128, 32, 32, 32), Rect2(128, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_22": {
		"name": "Desk 22",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(160, 32, 32, 32), Rect2(160, 32, 32, 32), Rect2(160, 32, 32, 32), Rect2(160, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_23": {
		"name": "Desk 23",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(192, 32, 32, 32), Rect2(192, 32, 32, 32), Rect2(192, 32, 32, 32), Rect2(192, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_24": {
		"name": "Desk 24",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(224, 32, 32, 32), Rect2(224, 32, 32, 32), Rect2(224, 32, 32, 32), Rect2(224, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_25": {
		"name": "Desk 25",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(256, 32, 32, 32), Rect2(256, 32, 32, 32), Rect2(256, 32, 32, 32), Rect2(256, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_26": {
		"name": "Desk 26",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(288, 32, 32, 32), Rect2(288, 32, 32, 32), Rect2(288, 32, 32, 32), Rect2(288, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_27": {
		"name": "Desk 27",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(320, 32, 32, 32), Rect2(320, 32, 32, 32), Rect2(320, 32, 32, 32), Rect2(320, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_28": {
		"name": "Desk 28",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(352, 32, 32, 32), Rect2(352, 32, 32, 32), Rect2(352, 32, 32, 32), Rect2(352, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_29": {
		"name": "Desk 29",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(384, 32, 32, 32), Rect2(384, 32, 32, 32), Rect2(384, 32, 32, 32), Rect2(384, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_30": {
		"name": "Desk 30",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(416, 32, 32, 32), Rect2(416, 32, 32, 32), Rect2(416, 32, 32, 32), Rect2(416, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_31": {
		"name": "Desk 31",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(448, 32, 32, 32), Rect2(448, 32, 32, 32), Rect2(448, 32, 32, 32), Rect2(448, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_32": {
		"name": "Desk 32",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(480, 32, 32, 32), Rect2(480, 32, 32, 32), Rect2(480, 32, 32, 32), Rect2(480, 32, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_33": {
		"name": "Desk 33",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(0, 64, 32, 32), Rect2(0, 64, 32, 32), Rect2(0, 64, 32, 32), Rect2(0, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_34": {
		"name": "Desk 34",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(32, 64, 32, 32), Rect2(32, 64, 32, 32), Rect2(32, 64, 32, 32), Rect2(32, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_35": {
		"name": "Desk 35",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(64, 64, 32, 32), Rect2(64, 64, 32, 32), Rect2(64, 64, 32, 32), Rect2(64, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_36": {
		"name": "Desk 36",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(96, 64, 32, 32), Rect2(96, 64, 32, 32), Rect2(96, 64, 32, 32), Rect2(96, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_37": {
		"name": "Desk 37",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(128, 64, 32, 32), Rect2(128, 64, 32, 32), Rect2(128, 64, 32, 32), Rect2(128, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_38": {
		"name": "Desk 38",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(160, 64, 32, 32), Rect2(160, 64, 32, 32), Rect2(160, 64, 32, 32), Rect2(160, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_39": {
		"name": "Desk 39",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(192, 64, 32, 32), Rect2(192, 64, 32, 32), Rect2(192, 64, 32, 32), Rect2(192, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_40": {
		"name": "Desk 40",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(224, 64, 32, 32), Rect2(224, 64, 32, 32), Rect2(224, 64, 32, 32), Rect2(224, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_41": {
		"name": "Desk 41",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(256, 64, 32, 32), Rect2(256, 64, 32, 32), Rect2(256, 64, 32, 32), Rect2(256, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_42": {
		"name": "Desk 42",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(288, 64, 32, 32), Rect2(288, 64, 32, 32), Rect2(288, 64, 32, 32), Rect2(288, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_43": {
		"name": "Desk 43",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(320, 64, 32, 32), Rect2(320, 64, 32, 32), Rect2(320, 64, 32, 32), Rect2(320, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_44": {
		"name": "Desk 44",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(352, 64, 32, 32), Rect2(352, 64, 32, 32), Rect2(352, 64, 32, 32), Rect2(352, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_45": {
		"name": "Desk 45",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(384, 64, 32, 32), Rect2(384, 64, 32, 32), Rect2(384, 64, 32, 32), Rect2(384, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_46": {
		"name": "Desk 46",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(416, 64, 32, 32), Rect2(416, 64, 32, 32), Rect2(416, 64, 32, 32), Rect2(416, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_47": {
		"name": "Desk 47",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(448, 64, 32, 32), Rect2(448, 64, 32, 32), Rect2(448, 64, 32, 32), Rect2(448, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_48": {
		"name": "Desk 48",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(480, 64, 32, 32), Rect2(480, 64, 32, 32), Rect2(480, 64, 32, 32), Rect2(480, 64, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_49": {
		"name": "Desk 49",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(0, 96, 32, 32), Rect2(0, 96, 32, 32), Rect2(0, 96, 32, 32), Rect2(0, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_50": {
		"name": "Desk 50",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(32, 96, 32, 32), Rect2(32, 96, 32, 32), Rect2(32, 96, 32, 32), Rect2(32, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_51": {
		"name": "Desk 51",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(64, 96, 32, 32), Rect2(64, 96, 32, 32), Rect2(64, 96, 32, 32), Rect2(64, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_52": {
		"name": "Desk 52",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(96, 96, 32, 32), Rect2(96, 96, 32, 32), Rect2(96, 96, 32, 32), Rect2(96, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_53": {
		"name": "Desk 53",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(128, 96, 32, 32), Rect2(128, 96, 32, 32), Rect2(128, 96, 32, 32), Rect2(128, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_54": {
		"name": "Desk 54",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(160, 96, 32, 32), Rect2(160, 96, 32, 32), Rect2(160, 96, 32, 32), Rect2(160, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_55": {
		"name": "Desk 55",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(192, 96, 32, 32), Rect2(192, 96, 32, 32), Rect2(192, 96, 32, 32), Rect2(192, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_56": {
		"name": "Desk 56",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(224, 96, 32, 32), Rect2(224, 96, 32, 32), Rect2(224, 96, 32, 32), Rect2(224, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_57": {
		"name": "Desk 57",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(256, 96, 32, 32), Rect2(256, 96, 32, 32), Rect2(256, 96, 32, 32), Rect2(256, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_58": {
		"name": "Desk 58",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(288, 96, 32, 32), Rect2(288, 96, 32, 32), Rect2(288, 96, 32, 32), Rect2(288, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_59": {
		"name": "Desk 59",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(320, 96, 32, 32), Rect2(320, 96, 32, 32), Rect2(320, 96, 32, 32), Rect2(320, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_60": {
		"name": "Desk 60",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(352, 96, 32, 32), Rect2(352, 96, 32, 32), Rect2(352, 96, 32, 32), Rect2(352, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_61": {
		"name": "Desk 61",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(384, 96, 32, 32), Rect2(384, 96, 32, 32), Rect2(384, 96, 32, 32), Rect2(384, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_62": {
		"name": "Desk 62",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(416, 96, 32, 32), Rect2(416, 96, 32, 32), Rect2(416, 96, 32, 32), Rect2(416, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_63": {
		"name": "Desk 63",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(448, 96, 32, 32), Rect2(448, 96, 32, 32), Rect2(448, 96, 32, 32), Rect2(448, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
	"desk_64": {
		"name": "Desk 64",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [Rect2(480, 96, 32, 32), Rect2(480, 96, 32, 32), Rect2(480, 96, 32, 32), Rect2(480, 96, 32, 32)],
		"collision_sizes": [Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)],
		"collision_offsets": [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	},
}