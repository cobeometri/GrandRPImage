Config = {}
Config.Location = vector3(-960.12, 7769.52, 618.66)
Config.Win = vector3(-1084.56, 7769.47, 618.17)
Config.GRTT = vector3(228.6027, -905.5247, 30.6920)

Config.GAME_TIME = 1800

-- Giờ tự mở event (giờ MÁY CHỦ thực, dùng os.date). Đến giờ -> mở cửa tham gia
-- trong Config.GAME_TIME giây + đếm ngược trên HUD; hết giờ tự đóng.
Config.AutoStart = {
    [10] = true,
    [14] = true,
    [17] = true,
    [21] = true
}

-- Panel đếm ngược event (codem-supreme-hud)
Config.EventTimer = {
    id    = 'gta5vn_parkour',
    label = 'Parkour',
    color = '#ff5c5c',
    icon  = 'P',
}

-- Điểm tương tác trong khu parkour (qs-textui + lib.points)
Config.Points = {
    -- Rời trò chơi (gần điểm xuất phát) -> về thành phố (Config.GRTT)
    Quit = vector3(-959.7880, 7774.3594, 619.6622),
    -- Trở về thành phố (chỉ hiện SAU KHI thắng, gần đích) -> về thành phố
    ReturnCity = vector3(-1106.8502, 7769.3916, 619.1922),
}
Config.PointInteractDist = 2.0   -- khoảng cách bấm E để tương tác
Config.PointMarkerDist = 20.0    -- khoảng cách bắt đầu vẽ marker (để member nhận biết từ xa)
Config.PointMarkerColor = {
    Quit       = { r = 255, g = 92,  b = 92  },   -- đỏ: rời trò chơi
    ReturnCity = { r = 92,  g = 220, b = 120 },   -- xanh: trở về thành phố
}

Config.Checkpoints = {
    vector3(-1008.65, 7748.99, 624.01),
    vector3(-1053.94, 7759.09, 601.41),
    vector3(-1057.11, 7749.83, 617.6)

}

Config.MinValidTime = 8000
Config.MaxValidTime = Config.GAME_TIME * 1000
Config.Rewards = {
    Completion = {
        { type = 'money', account = 'money', amount = 5000 },
    },
    RecordBonus = {
        { type = 'money', account = 'bank', amount = 25000 },
    },
}

-- ============================================================
-- BẢNG XẾP HẠNG (NUI)
-- ============================================================
Config.Leaderboard = {
    MaxRows = 10,   -- số dòng top hiển thị (HUD + popup)
}