local _, Private = ...

------------------------------------------------------------
-- Item Types / Slot Modifiers
------------------------------------------------------------

Private.ITEM_TYPES = {
	INVTYPE_RELIC = { SlotMOD = 0.3164, ItemSlot = 18 },
	INVTYPE_TRINKET = { SlotMOD = 0.5625, ItemSlot = 33 },
	INVTYPE_2HWEAPON = { SlotMOD = 2.0000, ItemSlot = 16 },
	INVTYPE_WEAPONMAINHAND = { SlotMOD = 1.0000, ItemSlot = 16 },
	INVTYPE_WEAPONOFFHAND = { SlotMOD = 1.0000, ItemSlot = 17 },
	INVTYPE_RANGED = { SlotMOD = 0.3164, ItemSlot = 18 },
	INVTYPE_THROWN = { SlotMOD = 0.3164, ItemSlot = 18 },
	INVTYPE_RANGEDRIGHT = { SlotMOD = 0.3164, ItemSlot = 18 },
	INVTYPE_SHIELD = { SlotMOD = 1.0000, ItemSlot = 17 },
	INVTYPE_WEAPON = { SlotMOD = 1.0000, ItemSlot = 36 },
	INVTYPE_HOLDABLE = { SlotMOD = 1.0000, ItemSlot = 17 },

	INVTYPE_HEAD = { SlotMOD = 1.0000, ItemSlot = 1 },
	INVTYPE_NECK = { SlotMOD = 0.5625, ItemSlot = 2 },
	INVTYPE_SHOULDER = { SlotMOD = 0.7500, ItemSlot = 3 },
	INVTYPE_CHEST = { SlotMOD = 1.0000, ItemSlot = 5 },
	INVTYPE_ROBE = { SlotMOD = 1.0000, ItemSlot = 5 },
	INVTYPE_WAIST = { SlotMOD = 0.7500, ItemSlot = 6 },
	INVTYPE_LEGS = { SlotMOD = 1.0000, ItemSlot = 7 },
	INVTYPE_FEET = { SlotMOD = 0.7500, ItemSlot = 8 },
	INVTYPE_WRIST = { SlotMOD = 0.5625, ItemSlot = 9 },
	INVTYPE_HAND = { SlotMOD = 0.7500, ItemSlot = 10 },
	INVTYPE_FINGER = { SlotMOD = 0.5625, ItemSlot = 31 },
	INVTYPE_CLOAK = { SlotMOD = 0.5625, ItemSlot = 15 },
	INVTYPE_BODY = { SlotMOD = 0.0000, ItemSlot = 4 },
}

------------------------------------------------------------
-- Default Settings
------------------------------------------------------------

Private.DEFAULT_SETTINGS = {
	Player = 1,
	Item = 1,
	Compare = -1,
	Level = -1,
}

------------------------------------------------------------
-- GearScore Formula Tables
------------------------------------------------------------

Private.FORMULA = {
	A = {
		[4] = { A = 91.45,  B = 0.65   },
		[3] = { A = 81.375, B = 0.8125 },
		[2] = { A = 73.0,   B = 1.0    },
	},
	B = {
		[4] = { A = 26.0, B = 1.2  },
		[3] = { A = 0.75, B = 1.8  },
		[2] = { A = 8.0,  B = 2.0  },
		[1] = { A = 0.0,  B = 2.25 },
	},
}

------------------------------------------------------------
-- Quality / Color Scale
------------------------------------------------------------

Private.QUALITY = {
	[6000] = {
		Red =   { A = 0.94, B = 5000, C = 0.00006, D = 1 },
		Green = { A = 0.47, B = 5000, C = 0.00047, D = -1 },
		Blue =  { A = 0.00, B = 0,    C = 0,       D = 0 },
		Description = "Legendary",
	},
	[5000] = {
		Red =   { A = 0.69, B = 4000, C = 0.00025, D = 1 },
		Green = { A = 0.28, B = 4000, C = 0.00019, D = 1 },
		Blue =  { A = 0.97, B = 4000, C = 0.00096, D = -1 },
		Description = "Epic",
	},
	[4000] = {
		Red =   { A = 0.00, B = 3000, C = 0.00069, D = 1 },
		Green = { A = 0.50, B = 3000, C = 0.00022, D = -1 },
		Blue =  { A = 1.00, B = 3000, C = 0.00003, D = -1 },
		Description = "Superior",
	},
	[3000] = {
		Red =   { A = 0.12, B = 2000, C = 0.00012, D = -1 },
		Green = { A = 1.00, B = 2000, C = 0.00050, D = -1 },
		Blue =  { A = 0.00, B = 2000, C = 0.00100, D = 1 },
		Description = "Uncommon",
	},
	[2000] = {
		Red =   { A = 1.00, B = 1000, C = 0.00088, D = -1 },
		Green = { A = 1.00, B = 0,    C = 0.00000, D = 0 },
		Blue =  { A = 1.00, B = 1000, C = 0.00100, D = -1 },
		Description = "Common",
	},
	[1000] = {
		Red =   { A = 0.55, B = 0, C = 0.00045, D = 1 },
		Green = { A = 0.55, B = 0, C = 0.00045, D = 1 },
		Blue =  { A = 0.55, B = 0, C = 0.00045, D = 1 },
		Description = "Trash",
	},
}