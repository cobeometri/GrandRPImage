Config = {}

Config.Dependencies = {}

Config.Settings = {
	locale = {
		["KILLED YOU"] = "ĐÃ HẠ BẠN",
		["KILLED"] = "ĐÃ HẠ GỤC",
		["KILLED BY"] = "BỊ HẠ GỤC BỞI",
		["OUTGOING"] = "GÂY RA",
		["COMBAT REPORT"] = "BÁO CÁO GIAO TRANH",
		["INCOMING"] = "NHẬN VÀO",
		["COMBAT TIME"] = "THỜI GIAN",
		["DPS"] = "DPS",
	},
	combatTimeout = 30000,
}

Config.ExitLog = {
	duration = 120000,
}

Config.EnableModules = {
	["Newbie"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["CombatReport"] = {
		enabled = true,
		client = true,
		priority = 1,
	},
	["ExitLog"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["Bucket"] = {
		enabled = true,
		client = true,
		priority = 1,
	},
	["Bone"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["Vip"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["EXP"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["MapDetails"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["BuuCuc"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["RadialVehicle"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["RadialPlayer"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["RadialPingJob"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["RadialUtility"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["RadialPolice"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["Rental"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["Zone"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["VehicleBlacklist"] = {
		enabled = true,
		client = true,
		priority = 2,
	},
	["Population"] = {
		enabled = true,
		client = true,
		priority = 1,
	},
}

Config.RadialJobs = {
    ems     = { 'ambulance' },
    police  = { 'police', 'reporter' },
    pingjob = { 'ambulance', 'mechanic' },
}

Config.PoliceHighRankMinGrade = 7
Config.Debug = false
Config.Nui = false
Config.Dev = false
Config.Framework = "esx"
Config.ClientLazyLoad = false

Config.VipRank = {
	[0] = {
		label = "Vip 0",
		currentDonate = 0,
		level = 0,
	},
	[1] = {
		label = "Vip 1",
		currentDonate = 10000000,
		level = 1,
	},
	[2] = {
		label = "Vip 2",
		currentDonate = 20000000,
		level = 2,
	},
	[3] = {
		label = "Vip 3",
		currentDonate = 30000000,
		level = 3,
	},
	[4] = {
		label = "Vip 4",
		currentDonate = 40000000,
		level = 4,
	},
	[5] = {
		label = "Vip 5",
		currentDonate = 50000000,
		level = 5,
	},
	[6] = {
		label = "Vip 6",
		currentDonate = 60000000,
		level = 6,
	},
	[7] = {
		label = "Vip 7",
		currentDonate = 70000000,
		level = 7,
	},
	[8] = {
		label = "Vip 8",
		currentDonate = 80000000,
		level = 8,
	},
	[9] = {
		label = "Vip 9",
		currentDonate = 90000000,
		level = 9,
	},
	[10] = {
		label = "Vip 10",
		currentDonate = 100000000,
		level = 10,
	},
}

Config.EXP = {
    Timer = {
        LabelFormat = "X%d EXP",
        Color       = "#1eff00",
        Icon        = "X",
        IconUrls    = {
            [2] = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/inventory/exp_x2.webp",
            [4] = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/inventory/exp_x4.webp",
        },
    },
    ItemEXP = {
        exp_x2 = { enable = true, minut = 60, multiplier = 2 },
        exp_x4 = { enable = true, minut = 60, multiplier = 4 },
    }
}

Config.MapDetails = {
	[679] = {
		title = 'Khu Vực Đào Đá',
		description =
		'Khu vực đào đá là một khu vực trong game GTA 5 ở thành phố Los Santos. Khu vực này có rất nhiều đá có giá trị cao, và người chơi có thể đào đá để kiếm tiền.',
		cover_image = 'https://img.gta5-mods.com/q95/images/marines-secret-activity-4-president-comes-to-ls-gold-mining/df365c-20170217004526_1.jpg',
		reward = 'Phần Thưởng Nhận Được',
		items = {
			'diamond',
			'gold',
		}
	},
}

Config.BuuCuc = {
	markerCoords = vector3(83.0838, 133.8035, 79.5334),

	blip = {
		enabled = true,
		sprite = 88,
		color = 0,
		scale = 1.2,
		label = "~q~[Chính Phủ]~s~ Bưu Điện",
	},

	pageLimit = 10,

	itemImageUrl = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/inventory/%s.webp",

	accountImages = {
		money = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/inventory/money.webp",
		bank = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/inventory/bank.webp",
		coin = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/inventory/coin.webp",
		black_money = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/inventory/black_money.webp",
	},
}

Config.Rental = {
	spawnPoints = {
		car = vector4(-56.07, -1097.94, 26.42, 110.0),
		boat = vector4(-810.92, -1499.0, 0.0, 110.0),
	},

	returnPoints = {
		car = {
			{
				label  = "Thuê Xe",
				coords = vector3(176.4056, -448.2265, 41.0955),
				radius = 5.0,
				blip   = { sprite = 357, color = 5, scale = 0.7 },
			},
			{
				label  = "Thuê Xe",
				coords = vector3(436.2417, -645.8737, 27.740),
				radius = 5.0,
				blip   = { sprite = 357, color = 5, scale = 0.7 },
			},
			{
				label  = "Thuê Xe",
				coords = vector3(-3052.2673, 220.3876, 15.2199),
				radius = 5.0,
				blip   = { sprite = 357, color = 5, scale = 0.7 },
			},
		},
		boat = {
			{
				label  = "Trả Thuyền - Bến La Puerta",
				coords = vector3(-789.19, -1490.78, 1.60),
				radius = 8.0,
				blip   = { sprite = 410, color = 38, scale = 0.7 },
			},
			{
				label  = "Trả Thuyền - Vịnh Paleto",
				coords = vector3(-1605.32, 5258.28, 2.07),
				radius = 8.0,
				blip   = { sprite = 410, color = 38, scale = 0.7 },
			},
		},
	},

	abandonTimeoutSeconds = 60,
	catalog = {
		car = {
			{
				model = "panto",
				label = "Panto",
				price_per_hour = 300,
				deposit = 5000,
				image = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/vehicle/panto.webp",
				topSpeed = 120,
				seats = 4,
			},
			{
				model = "asea",
				label = "Asea",
				price_per_hour = 450,
				deposit = 8000,
				image = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/vehicle/asea.webp",
				topSpeed = 150,
				seats = 4,
			},
			{
				model = "primo",
				label = "Primo",
				price_per_hour = 600,
				deposit = 12000,
				image = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/vehicle/primo.webp",
				topSpeed = 160,
				seats = 4,
			},
			{
				model = "felon",
				label = "Felon",
				price_per_hour = 900,
				deposit = 20000,
				image = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/vehicle/felon.webp",
				topSpeed = 200,
				seats = 4,
			},
			{
				model = "faggio",
				label = "Faggio",
				price_per_hour = 150,
				deposit = 2000,
				image = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/vehicle/faggio.webp",
				topSpeed = 90,
				seats = 1,
			},
		},
		boat = {
			{
				model = "dinghy",
				label = "Dinghy",
				price_per_hour = 500,
				deposit = 10000,
				image = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/vehicle/dinghy.webp",
				topSpeed = 120,
				seats = 4,
			},
			{
				model = "seashark",
				label = "Seashark",
				price_per_hour = 800,
				deposit = 15000,
				image = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/vehicle/seashark.webp",
				topSpeed = 150,
				seats = 2,
			},
			{
				model = "jetmax",
				label = "Jetmax",
				price_per_hour = 2000,
				deposit = 50000,
				image = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/vehicle/jetmax.webp",
				topSpeed = 180,
				seats = 4,
			},
		},
	},

	durations = { 1, 2, 3, 4 },

	damageFeeMultiplier = 1.0,

	lateReturnGrace = 0,
	lateReturnPenaltyMultiplier = 0,

	expiryWarningSeconds = 300,

	vehicleIconUrlTemplate = "https://raw.githubusercontent.com/cobeometri/GrandRPImage/refs/heads/main/images/vehicle/%s.webp",
	codemEventTimer = {
		car = {
			id    = "gta5vn_rental_car",
			label = "Thuê Xe Còn Lại",
			icon  = "🚗",
			color = "#34c759",
		},
		boat = {
			id    = "gta5vn_rental_boat",
			label = "Thuê Thuyền Còn Lại",
			icon  = "⛵",
			color = "#007aff",
		},
		abandonWarning = {
			id    = "gta5vn_rental_abandon",
			label = "Phương Tiện Thuê Sẽ Bị Xoá Sau",
			icon  = "⚠",
			color = "#ff3b30",
		},
	},
}

Config.Zone = {
	blip = {
		enabled = true,
		alpha   = 96,
	},
	greenZoneSafety = {
		invincible = true,
		disableWeapons = true,
		clearBloodDamage = true,
		disableFriendlyFire = true,
		zeroWeaponDamage = true,
		speedLimit = 0,
	},
	redZoneSafety = {
		blockEmotes = true,
		emoteResource = "cdev_emotemenu",
	},
	rdmRule = {
		enabled = true,
		killThreshold = 3,
		windowSeconds = 300,
		jailMinutes = 200,
		jailReason = "Vô cớ giết người (RDM) - %d kill trong %d phút",
		exemptJobs = { "police", "sheriff", "lspd", "fbi",},
		exemptSameJob = true,

		whitelistWeapons = {
			["WEAPON_FALL"]                 = true,
			["WEAPON_DROWNING"]             = true,
			["WEAPON_DROWNING_IN_VEHICLE"]  = true,
			["WEAPON_FIRE"]                 = true,
			["WEAPON_EXPLOSION"]            = true,
			["WEAPON_RAMMED_BY_CAR"]        = true,
			["WEAPON_RUN_OVER_BY_CAR"]      = true,
			["WEAPON_ANIMAL"]               = true,
			["WEAPON_COUGAR"]               = true,
			["WEAPON_BARBED_WIRE"]          = true,
			["WEAPON_BLEEDING"]             = true,
			["WEAPON_ELECTRIC_FENCE"]       = true,
		},

		exemptHours = {},
	},
	dirtyJobZones = {
		{ id = "tromcho",          resource = "gta5vn_tromcho",      coords = vector3(-348.782, 484.7171, 113.34),  radius = 200.0 },
		{ id = "graverobbery",     resource = "gta5vn_graverobbery", coords = vector3(-1711.0, -185.0, 57.0),       radius = 130.0 },
		{ id = "drug_weed_farm",   resource = "gta5vn_drugsystem",   coords = vector3(312.8, 4323.9, 48.3),         radius = 120.0 },
		{ id = "drug_cocain_farm", resource = "gta5vn_drugsystem",   coords = vector3(1856.7, 4917.92, 45.64),      radius = 120.0 },
		{ id = "drug_opium_farm",  resource = "gta5vn_drugsystem",   coords = vector3(-1817.57, 1995.75, 126.84),   radius = 120.0 },
		{ id = "drug_weed_lab",    resource = "gta5vn_drugsystem",   coords = vector3(3818.94, 4442.67, 2.81),      radius = 100.0 },
		{ id = "drug_cocain_lab",  resource = "gta5vn_drugsystem",   coords = vector3(971.87, -2157.67, 29.48),     radius = 100.0 },
		{ id = "drug_opium_lab",   resource = "gta5vn_drugsystem",   coords = vector3(2194.56, 5595.15, 53.76),     radius = 100.0 },
	},
	zones = {
		{
			id     = "white_mo",
			type   = "white",
			shape  = "sphere",
			coords = vector3(1440.6427, 1110.1724, 114.2424),
			radius = 120.0,
		},
		{
			id     = "white_golf",
			type   = "white",
			shape  = "sphere",
			coords = vector3(-1206.9437, 86.7921, 56.6082),
			radius = 130.0,
		},
		{
			id     = "red_chumash",
			type   = "red",
			shape  = "sphere",
			coords = vector3(-1722.7268, -192.7156, 58.4501),
			radius = 140.0,
		},
		{
			id     = "green_pillbox",
			type   = "green",
			shape  = "sphere",
			coords = vector3(298.5, -584.4, 43.3),
			radius = 80.0,
		},
	},
}

Config.VehicleBlacklist = {
	notifyDuration = 4000,
	vehicles = {
		['police']    = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là xe cảnh sát.' },
		['police2']   = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là xe cảnh sát.' },
		['police3']   = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là xe cảnh sát.' },
		['police4']   = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là xe cảnh sát.' },
		['policet']   = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là xe cảnh sát.' },
		['policeb']   = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là xe cảnh sát.' },
		['polmav']    = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là trực thăng cảnh sát.' },
		['pranger']   = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là xe cảnh sát.' },
		['riot']      = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là xe cảnh sát.' },
		['riot2']     = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là xe cảnh sát.' },
		['sheriff']   = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là xe cảnh sát.' },
		['sheriff2']  = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là xe cảnh sát.' },
		['poldurango']       = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là xe cảnh sát.' },
		['polcoach']      = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là xe cảnh sát.' },
		['polgt63']  = { allowedJobs = { 'police', 'reporter' }, message = 'Đây là tàu cảnh sát.' },
		['ambulance'] = { allowedJobs = { 'ambulance' },          message = 'Đây là xe cứu thương.' },
		['polmustang'] = { allowedJobs = { 'ambulance' },          message = 'Đây là xe cứu thương.' },
		['lguard']    = { allowedJobs = { 'ambulance' },          message = 'Đây là xe cứu hộ.' },
	},
}

Config.Population = {
	density = {
		ped = 0.0,
		scenarioInterior = 0.0,
		scenarioExterior = 0.0,
		vehicle = 0.25,
		randomVehicle = 0.25,
		parked = 0.2,
		ambientRange = 1.0,
	},
	world = {
		randomCops = false,
		garbageTrucks = false,
		randomBoats = false,
	},
}

function L(key, ...)
	if Config.Settings.locale[key] then
		return string.format(Config.Settings.locale[key], ...)
	else
		return key
	end
end
