if not lib then return end
local ESX = exports['es_extended']:getSharedObject()
local IsInEvent = false
local TempCoords = nil

local IsFrozen = false

local IsWon = false
local CurrentCheckpoint = 0
local TempHp = 200
local RunStartMs = nil          -- mốc bắt đầu chạy (client, để hiển thị đồng hồ); thời gian chính thức do server đo
local LeaderboardOpen = false

local function DrawText2D(text, font, x, y, scale, r, g, b, a)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

--- Định dạng ms -> mm:ss.mmm
---@param ms number
---@return string
local function FormatTime(ms)
    if not ms or ms < 0 then ms = 0 end
    local totalSec = math.floor(ms / 1000)
    local minutes = math.floor(totalSec / 60)
    local seconds = totalSec % 60
    local millis = math.floor(ms % 1000)
    return ("%02d:%02d.%03d"):format(minutes, seconds, millis)
end

--- Mở bảng xếp hạng (NUI). Lấy dữ liệu từ server qua callback.
---@param highlightMs number|nil thời gian vừa đạt (để highlight, nil nếu mở thủ công)
local function OpenLeaderboard(highlightMs)
    if LeaderboardOpen then return end
    local data = lib.callback.await('gta5vn_parkour:getLeaderboard', false)
    if not data then return end
    LeaderboardOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action      = 'open',
        rows        = data.rows or {},
        myBest      = data.myBest,
        highlightMs = highlightMs,
    })
end

local function CloseLeaderboard()
    if not LeaderboardOpen then return end
    LeaderboardOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

--- HUD góc phải (top 10) — display-only, KHÔNG cần NUI focus.
--- Dùng cho cả lần hiện đầu và refresh khi standings đổi.
local function ShowSidebar()
    if not IsInEvent then return end
    local data = lib.callback.await('gta5vn_parkour:getLeaderboard', false)
    if not data then return end
    SendNUIMessage({ action = 'sidebar', rows = data.rows or {}, myBest = data.myBest })
end

local function HideSidebar()
    SendNUIMessage({ action = 'sidebarHide' })
end

-- ============================================================
-- ĐIỂM TƯƠNG TÁC (lib.points + qs-textui drawText3D + marker 24)
--   Rời trò chơi / Trở về thành phố
-- ============================================================
local quitPoint, returnPoint

-- Rời event -> server xác nhận -> QuitEvent (teleport GRTT + cleanup)
local function leaveToCity()
    TriggerServerEvent("gta5vn_parkour:server:CommandQuit")
end

--- Vẽ marker 24 (vòng tròn dưới chân) tại điểm để member nhận biết từ xa.
---@param coords vector3
---@param col table {r,g,b}
local function drawPointMarker(coords, col)
    DrawMarker(24, coords.x, coords.y, coords.z - 0.95,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5,
        col.r, col.g, col.b, 150,
        false, false, 2, false, nil, nil, false)
end

local function createQuitPoint()
    if quitPoint then return end
    local c = Config.Points.Quit
    exports['qs-textui']:drawText3D(c.x, c.y, c.z -1.0, 'Rời trò chơi', 'gta5vn_parkour_quit', 'E')
    quitPoint = lib.points.new({ coords = c, distance = Config.PointMarkerDist })
    function quitPoint:nearby()
        drawPointMarker(self.coords, Config.PointMarkerColor.Quit)
        if self.currentDistance <= Config.PointInteractDist and IsControlJustReleased(0, 38) then
            leaveToCity()
        end
    end
end

local function createReturnPoint()
    if returnPoint then return end
    local c = Config.Points.ReturnCity
    exports['qs-textui']:drawText3D(c.x, c.y, c.z -1.0, 'Trở về thành phố', 'gta5vn_parkour_return', 'E')
    returnPoint = lib.points.new({ coords = c, distance = Config.PointMarkerDist })
    function returnPoint:nearby()
        drawPointMarker(self.coords, Config.PointMarkerColor.ReturnCity)
        if self.currentDistance <= Config.PointInteractDist and IsControlJustReleased(0, 38) then
            leaveToCity()
        end
    end
end

local function removeEventPoints()
    if quitPoint then quitPoint:remove(); quitPoint = nil end
    if returnPoint then returnPoint:remove(); returnPoint = nil end
    exports['qs-textui']:DeleteDrawText3D('gta5vn_parkour_quit')
    exports['qs-textui']:DeleteDrawText3D('gta5vn_parkour_return')
end

-- ============================================================
-- PANEL ĐẾM NGƯỢC EVENT (codem-supreme-hud) — hiện cho mọi người
-- ============================================================
RegisterNetEvent("gta5vn_parkour:client:EventOpened", function(remaining)
    if not remaining or remaining <= 0 then return end
    exports['codem-supreme-hud']:AddEventTimer({
        id       = Config.EventTimer.id,
        label    = Config.EventTimer.label,
        duration = remaining,
        color    = Config.EventTimer.color,
        icon     = Config.EventTimer.icon,
    })
end)

RegisterNetEvent("gta5vn_parkour:client:EventClosed", function()
    exports['codem-supreme-hud']:RemoveEventTimer(Config.EventTimer.id)
end)

-- Export cho NPC qs-interact gọi để tham gia (server kiểm tra event có đang mở không)
exports('JoinParkour', function()
    TriggerServerEvent("gta5vn_parkour:server:CommandJoin")
end)

AddEventHandler("esx:playerLoaded", function()
    local playerCoords = GetEntityCoords(cache.ped)
    if #(playerCoords - Config.Location) < 200.0 then
        SetEntityCoords(cache.ped, Config.GRTT)
    end
end)

RegisterNetEvent("gta5vn_parkour:client:JoinEvent", function()
    -- if exports.wasabi_ambulance:isPlayerDead() or exports.wasabi_police:isPlayerCuffed() then return end

    if lib.progressActive() then
        ESX.ShowNotification("Không thể tham gia khi đang dỡ việc", "error")
        return
    end

    if cache.vehicle then
        ESX.ShowNotification("Không thể tham gia khi đang ở trên xe", "error")
        return
    end

    if not IsInEvent then
        TriggerServerEvent("tnt-anticl:JoinEvent", "Parkour")
        Wait(500)
        
        TriggerServerEvent("gta5vn_parkour:server:JoinEvent")
        LocalPlayer.state:set("canEmote", false, true)

        -- exports['tnt_misc']:ActiveSafeMode()
        IsInEvent = true
        DisplayRadar(false)
        TempCoords = GetEntityCoords(cache.ped)
        SetEntityCoords(cache.ped, Config.Location)
        FreezeEntityPosition(cache.ped, true)
        CurrentCheckpoint = 0
        TempHp = GetEntityHealth(cache.ped)
        IsWon = false
        IsFrozen = true
        RunStartMs = nil
        ShowSidebar()
        SendNUIMessage({ action = 'progress', cp = 0, total = #Config.Checkpoints })

        -- Điểm "Rời trò chơi" gần điểm xuất phát
        createQuitPoint()

        CreateThread(function()
            while IsInEvent do
                local playerCoords = GetEntityCoords(cache.ped)

                if IsFrozen then
                    DrawText2D("~r~Chú Ý~w~: Khi map đã được tải xong. Nhấn ~y~[SPACE - PHÍM CÁCH]~w~ để bỏ đóng băng", 4, 0.5, 0.9, 0.3,
                        255, 255, 255, 180)
                    if IsControlJustReleased(0, 22) then
                        FreezeEntityPosition(cache.ped, false)
                        IsFrozen = false
                        RunStartMs = GetGameTimer()
                        TriggerServerEvent("gta5vn_parkour:server:StartRun")
                        SendNUIMessage({ action = 'timerStart' })
                    end
                else
                    if not IsWon then
                        DrawMarker(1, Config.Win.x, Config.Win.y, Config.Win.z - 1, 0, 0, 0, 0, 0, 0, 3.0, 3.0, 100.0,
                            255, 92, 92, 200,
                            false,
                            true, 2, false, false, false, false)
                        DrawMarker(4, Config.Win.x, Config.Win.y, Config.Win.z - 1, 0, 0, 0, 0, 0, 0, 3.0, 3.0, 10.0, 255,
                            0, 0, 200,
                            false,
                            true, 2, false, false, false, false)

                        local NextCheckpoint = CurrentCheckpoint + 1
                        if Config.Checkpoints[NextCheckpoint] then
                            local checkpointCoords = Config.Checkpoints[NextCheckpoint]
                            DrawMarker(1, checkpointCoords.x, checkpointCoords.y, checkpointCoords.z - 1, 0, 0, 0, 0, 0,
                                0, 3.0,
                                3.0, 100.0,
                                255, 255, 0, 200,
                                false,
                                true, 2, false, false, false, false)
                            DrawMarker(4, checkpointCoords.x, checkpointCoords.y, checkpointCoords.z - 1, 0, 0, 0, 0, 0,
                                0, 3.0,
                                3.0, 10.0,
                                255,
                                241, 92, 100,
                                false,
                                true, 2, false, false, false, false)
                            if #(playerCoords - checkpointCoords) <= 3.0 then
                                CurrentCheckpoint = NextCheckpoint
                                SendNUIMessage({ action = 'progress', cp = CurrentCheckpoint, total = #Config.Checkpoints })
                            end
                        end
                    end

                    if #(playerCoords - Config.Win) <= 3.0 then
                        if not IsWon then
                            IsWon = true
                            TriggerServerEvent("gta5vn_parkour:server:PlayerWon")
                            -- Dừng đồng hồ ngay (thời gian chính thức từ server sẽ chốt lại ở WinResult)
                            SendNUIMessage({ action = 'timerStop' })
                            SendNUIMessage({ action = 'progress', cp = #Config.Checkpoints, total = #Config.Checkpoints })
                        end
                    end

                    if #(playerCoords - Config.Location) >= 200.0 then
                        if not IsWon then 
                            SetEntityCoords(cache.ped,
                                CurrentCheckpoint > 0 and Config.Checkpoints[CurrentCheckpoint] or Config.Location)
                        else 
                            SetEntityCoords(cache.ped,
                                Config.Location)
                        end 
                    end
                end
                Wait(0)
            end
            FreezeEntityPosition(cache.ped, false)
        end)
    end
end)

RegisterNetEvent("gta5vn_parkour:client:QuitEvent", function()
    if IsInEvent then
        IsInEvent = false
        RunStartMs = nil
        HideSidebar()
        removeEventPoints()

        LocalPlayer.state:set("canEmote", true, true)
        TriggerServerEvent("gta5vn_parkour:server:QuitEvent")
        TriggerEvent('wasabi_ambulance:revive')
        if TempHp then 
            SetEntityHealth(cache.ped, TempHp)
        end 
        -- exports['tnt_misc']:DisableSafeMode()
        DisplayRadar(true)
        SetEntityCoords(cache.ped, Config.GRTT)
        FreezeEntityPosition(cache.ped, true)
        local time = GetGameTimer()
        while (not HasCollisionLoadedAroundEntity(cache.ped) and (GetGameTimer() - time) < 5000) do
            Wait(0)
        end
        FreezeEntityPosition(cache.ped, false)
    else
        local playerCoords = GetEntityCoords(cache.ped)
        if #(playerCoords - Config.Location) <= 150.0 then
            SetEntityCoords(cache.ped, Config.GRTT)
        end
    end
end)

RegisterNetEvent("esx:onPlayerDeath", function()
    if IsInEvent then
        if IsWon then
            TriggerEvent("gta5vn_parkour:client:QuitEvent")
        else
            TriggerEvent('wasabi_ambulance:revive')
        end
    end
end)


RegisterNetEvent("gta5vn_parkour:client:ResetCheckpoint", function()
    CurrentCheckpoint = 0
end)

-- Server báo kết quả về đích: thời gian chính thức + hạng + có phá kỷ lục không.
RegisterNetEvent("gta5vn_parkour:client:WinResult", function(data)
    if not data then return end
    RunStartMs = nil
    local msg = ("Hoàn thành! Thời gian: %s • Hạng #%d"):format(FormatTime(data.timeMs), data.rank or 0)
    if data.isRecord then
        msg = ("🏆 KỶ LỤC MỚI! %s"):format(FormatTime(data.timeMs))
    end
    ESX.ShowNotification(msg, data.isRecord and "success" or "info", 8000)
    -- Chốt đồng hồ bằng thời gian chính thức từ server + cập nhật HUD top 10
    SendNUIMessage({ action = 'timerStop', finalMs = data.timeMs })
    ShowSidebar()

    -- Mở điểm "Trở về thành phố" (gần đích) sau khi thắng
    createReturnPoint()
    -- Tự hiện popup bảng xếp hạng, highlight thành tích vừa đạt
    OpenLeaderboard(data.bestMs or data.timeMs)
end)

-- Có người về đích -> server báo các participant khác refresh HUD top 10 (event-driven, không polling)
RegisterNetEvent("gta5vn_parkour:client:RefreshBoard", function()
    ShowSidebar()
end)

-- Đóng BXH từ NUI (phím ESC / nút đóng).
RegisterNUICallback('close', function(_, cb)
    CloseLeaderboard()
    cb('ok')
end)
