local Impl = NewImpl("Rental")

local isNuiOpen = false
local isBusy = false
local activeRentalVehicle = nil
local activeRentalData = nil
local inReturnZone = false
local abandonStartedAt = nil
local expireFiredAt = nil
local lastWarningSent = false
local hudThread = nil
local abandonThread = nil
local pendingSpawnCoords = nil

function Impl:Init()
	self:LogInfo("%s initialized", self:GetName())
end

function Impl:OnReady()
	self:CreateReturnZones()
	self:RegisterNuiCallbacks()
	self:RegisterExports()
	SetTimeout(2000, function()
		self:SyncActiveRental()
	end)
end

function Impl:OnDestroy()
	hudThread = nil
	abandonThread = nil
	self:ClearCodemTimer()
end

function Impl:CreateReturnZones()
	for _, points in pairs(Config.Rental.returnPoints or {}) do
		for _, p in ipairs(points) do
			if p.blip then
				local blip = AddBlipForCoord(p.coords.x, p.coords.y, p.coords.z)
				SetBlipSprite(blip, p.blip.sprite or 357)
				SetBlipDisplay(blip, 4)
				SetBlipScale(blip, p.blip.scale or 0.7)
				SetBlipColour(blip, p.blip.color or 5)
				SetBlipAsShortRange(blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(p.label or "Trả phương tiện")
				EndTextCommandSetBlipName(blip)
			end
		end
	end

	Citizen.CreateThread(function()
		local activeTextIds = {}

		local function clearAllText()
			for id, _ in pairs(activeTextIds) do
				pcall(function()
					exports['qs-textui']:DeleteDrawText3D(id)
				end)
				activeTextIds[id] = nil
			end
		end

		while true do
			local sleep = 1000
			inReturnZone = false

			if activeRentalData then
				local category = activeRentalData.category
				local points = Config.Rental.returnPoints and Config.Rental.returnPoints[category] or {}
				local ped = PlayerPedId()
				local playerCoords = GetEntityCoords(ped)
				local playerInRentalVeh = false
				if activeRentalVehicle and DoesEntityExist(activeRentalVehicle) then
					local veh = GetVehiclePedIsIn(ped, false)
					playerInRentalVeh = (veh ~= 0 and veh == activeRentalVehicle)
				end

				for idx, p in ipairs(points) do
					local id = ("gta5vn_rental_return_%s_%d"):format(category, idx)
					local dist = #(playerCoords - p.coords)
					local radius = p.radius or 5.0

					if dist < 50.0 then
						sleep = 0
						DrawMarker(
							1,
							p.coords.x, p.coords.y, p.coords.z - 1.0,
							0.0, 0.0, 0.0,
							0.0, 0.0, 0.0,
							radius * 0.6, radius * 0.6, 0.8,
							255, 255, 255, 150,
							false, false, false, true, false, false, false
						)
					end

					if dist < radius and playerInRentalVeh then
						inReturnZone = true
						if not activeTextIds[id] then
							pcall(function()
								exports['qs-textui']:drawText3D(
									p.coords.x, p.coords.y, p.coords.z + 0.5,
									("Trả %s"):format(category == "boat" and "thuyền" or "xe"),
									id,
									"E"
								)
							end)
							activeTextIds[id] = true
						end
						if IsControlJustPressed(0, 38) then
							self:DoReturn()
						end
					else
						if activeTextIds[id] then
							pcall(function()
								exports['qs-textui']:DeleteDrawText3D(id)
							end)
							activeTextIds[id] = nil
						end
					end
				end
			else
				clearAllText()
			end

			Citizen.Wait(sleep)
		end
	end)
end

function Impl:OpenUI(category)
	if isNuiOpen then return end
	if category ~= "car" and category ~= "boat" then category = "car" end
	pendingSpawnCoords = self:FindNearestSpawnCoords(category)
	isNuiOpen = true
	SetNuiFocus(true, true)
	local catalogResp = lib.callback.await(ResourceName .. ":rental:getCatalog", false)
	local activeResp = lib.callback.await(ResourceName .. ":rental:getActiveRental", false)
	if activeResp and activeResp.data then
		activeRentalData = activeResp.data
		self:StartHud()
		self:ApplyCodemMainTimer()
	end
	SendNUIMessage({
		action = "rental:open",
		data = {
			locationKey = category,
			catalog = catalogResp and catalogResp.data or nil,
			active = activeResp and activeResp.data or nil,
		}
	})
end

function Impl:FindNearestSpawnCoords(category)
	local points = Config.Rental.returnPoints and Config.Rental.returnPoints[category]
	if not points or #points == 0 then return nil end
	local playerCoords = GetEntityCoords(PlayerPedId())
	local nearest, nearestDist = nil, math.huge
	for _, p in ipairs(points) do
		local d = #(playerCoords - p.coords)
		if d < nearestDist then
			nearest = p
			nearestDist = d
		end
	end
	if not nearest then return nil end
	if nearest.spawnCoords then
		return nearest.spawnCoords
	end
	return vector4(nearest.coords.x, nearest.coords.y, nearest.coords.z, 0.0)
end

function Impl:CloseUI()
	if not isNuiOpen then return end
	isNuiOpen = false
	SetNuiFocus(false, false)
	SendNUIMessage({ action = "rental:close" })
end

function Impl:RegisterNuiCallbacks()
	RegisterNUICallback("rental:close", function(_, cb)
		self:CloseUI()
		cb("ok")
	end)

	RegisterNUICallback("rental:closeReceipt", function(_, cb)
		if not isNuiOpen then
			SetNuiFocus(false, false)
		end
		cb("ok")
	end)

	RegisterNUICallback("rental:startRental", function(data, cb)
		if isBusy then cb({ status = 0, message = "Đang xử lý..." }); return end
		isBusy = true
		local function finish(resp) isBusy = false; cb(resp) end

		local hash = data and data.model and GetHashKey(data.model) or nil
		if not (hash and pcall(lib.requestModel, hash)) then
			finish({ status = 0, message = "Không tải được phương tiện, vui lòng thử lại" })
			return
		end

		local resp = lib.callback.await(ResourceName .. ":rental:startRental", false, data)
		if not resp or resp.status ~= 1 then
			SetModelAsNoLongerNeeded(hash)
			finish(resp or { status = 0, message = "Lỗi không xác định" })
			return
		end

		local ok, spawned = pcall(function() return self:SpawnRentalVehicle(resp.data, hash) end)
		if not (ok and spawned) then
			lib.callback.await(ResourceName .. ":rental:cancelRental", false)
			finish({ status = 0, message = "Không thể tạo xe — đã hoàn lại tiền" })
			return
		end

		activeRentalData = resp.data
		expireFiredAt = nil
		abandonStartedAt = nil
		self:StartHud()
		self:ApplyCodemMainTimer()
		finish(resp)
	end)

	RegisterNUICallback("rental:returnRental", function(_, cb)
		if isBusy then cb({ status = 0, message = "Đang xử lý..." }); return end
		if not activeRentalData then
			cb({ status = 0, message = "Không có phương tiện thuê" })
			return
		end
		isBusy = true
		local result = self:DoReturn()
		isBusy = false
		cb(result)
	end)

	RegisterNUICallback("rental:getHistory", function(data, cb)
		local resp = lib.callback.await(ResourceName .. ":rental:getHistory", false, data)
		cb(resp or { status = 0 })
	end)
end

function Impl:RegisterExports()
	exports("OpenRental", function(category)
		self:OpenUI(category or "car")
	end)

	exports("CloseRental", function()
		self:CloseUI()
	end)

	exports("IsPlayerRenting", function()
		return activeRentalData ~= nil
	end)

	exports("ReturnRental", function()
		return self:DoReturn()
	end)
end

function Impl:SpawnRentalVehicle(data, preloadedHash)
	if not data then return false end
	local sp = pendingSpawnCoords
		or (Config.Rental.spawnPoints and Config.Rental.spawnPoints[data.category])
	if not sp then
		self:LogError("Spawn point cho category %s không tồn tại", tostring(data.category))
		return false
	end
	pendingSpawnCoords = nil

	local modelHash = preloadedHash or GetHashKey(data.vehicleModel)
	ClearAreaOfVehicles(sp.x, sp.y, sp.z, 5.0, false, false, false, false, false)

	local veh = CreateVehicle(modelHash, sp.x, sp.y, sp.z, sp.w or 0.0, true, true)
	SetModelAsNoLongerNeeded(modelHash)
	if not veh or veh == 0 or not DoesEntityExist(veh) then
		self:LogError("CreateVehicle thất bại cho model %s", tostring(data.vehicleModel))
		return false
	end

	SetVehicleNumberPlateText(veh, data.plate)
	SetVehicleEngineOn(veh, true, true, false)
	SetVehicleFuelLevel(veh, 100.0)
	SetEntityAsMissionEntity(veh, true, true)

	TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)

	activeRentalVehicle = veh
	return true
end

function Impl:DespawnRentalVehicle()
	if activeRentalVehicle and DoesEntityExist(activeRentalVehicle) then
		SetEntityAsMissionEntity(activeRentalVehicle, true, true)
		DeleteVehicle(activeRentalVehicle)
	end
	activeRentalVehicle = nil
end

function Impl:DoReturn()
	if not activeRentalData then
		return { status = 0, message = "Không có phương tiện thuê" }
	end

	if not inReturnZone then
		local cat = activeRentalData.category
		return {
			status = 0,
			message = ("Hãy lái %s tới điểm trả gần nhất (xem trên bản đồ)"):format(
				cat == "boat" and "thuyền" or "xe"
			),
		}
	end

	local damageRatio = 1.0
	if activeRentalVehicle and DoesEntityExist(activeRentalVehicle) then
		local body = GetVehicleBodyHealth(activeRentalVehicle) / 1000.0
		local engine = GetVehicleEngineHealth(activeRentalVehicle) / 1000.0
		if body > 1 then body = 1 end
		if body < 0 then body = 0 end
		if engine > 1 then engine = 1 end
		if engine < 0 then engine = 0 end
		damageRatio = ((1 - body) + (1 - engine)) * 0.5
		if damageRatio < 0 then damageRatio = 0 end
		if damageRatio > 1 then damageRatio = 1 end
	end

	local resp = lib.callback.await(ResourceName .. ":rental:returnRental", false, {
		damageRatio = damageRatio,
	})
	if not resp or resp.status ~= 1 then
		return resp or { status = 0, message = "Lỗi không xác định" }
	end

	self:ClearLocalRentalState()
	if resp.data then
		self:ShowReceipt(resp.data)
	end
	return resp
end

function Impl:ClearLocalRentalState()
	self:DespawnRentalVehicle()
	activeRentalData = nil
	expireFiredAt = nil
	abandonStartedAt = nil
	self:StopHud()
	self:ClearCodemTimer()
	SendNUIMessage({ action = "rental:hud", data = nil })
end

function Impl:ShowReceipt(receipt)
	SendNUIMessage({ action = "rental:returned", data = receipt })
	if not isNuiOpen then
		SetNuiFocus(true, true)
	end
end

function Impl:SyncActiveRental()
	local resp = lib.callback.await(ResourceName .. ":rental:getActiveRental", false)
	if not resp or resp.status ~= 1 or not resp.data then return end
	activeRentalData = resp.data
	activeRentalVehicle = self:FindVehicleByPlate(resp.data.plate)
	self:StartHud()
	self:ApplyCodemMainTimer()
end

function Impl:FindVehicleByPlate(plate)
	if not plate or plate == "" then return nil end
	local pool = GetGamePool("CVehicle")
	for i = 1, #pool do
		local veh = pool[i]
		if DoesEntityExist(veh) then
			local text = GetVehicleNumberPlateText(veh)
			if text and text:gsub("%s+", "") == plate then
				SetEntityAsMissionEntity(veh, true, true)
				return veh
			end
		end
	end
	return nil
end

function Impl:StartHud()
	if hudThread then return end
	lastWarningSent = false
	hudThread = Citizen.CreateThread(function()
		while activeRentalData do
			local nowMs = GetCloudTimeAsInt() * 1000
			local expireMs = activeRentalData.expireAt or 0
			local remainingMs = expireMs - nowMs

			SendNUIMessage({
				action = "rental:hud",
				data = {
					vehicleLabel = activeRentalData.vehicleLabel,
					plate = activeRentalData.plate,
					category = activeRentalData.category,
					remainingMs = remainingMs,
					expireAt = expireMs,
				}
			})

			local warnSec = Config.Rental.expiryWarningSeconds or 300
			if not lastWarningSent and remainingMs > 0 and remainingMs < warnSec * 1000 then
				lastWarningSent = true
				lib.notify({
					title = "Thuê phương tiện",
					description = ("Còn dưới %d phút trước khi hết giờ!"):format(math.floor(warnSec / 60)),
					type = "warning",
					duration = 8000,
				})
			end

			if remainingMs <= 0 and not expireFiredAt then
				expireFiredAt = nowMs
				self:HandleClientExpire()
			end

			Citizen.Wait(1000)
		end
	end)

	if not abandonThread then
		abandonThread = Citizen.CreateThread(function()
			while activeRentalData do
				self:TickAbandonWatcher()
				Citizen.Wait(1000)
			end
			abandonThread = nil
		end)
	end
end

function Impl:StopHud()
	hudThread = nil
	abandonThread = nil
	lastWarningSent = false
end

function Impl:HandleClientExpire()
	self:LogInfo("Rental hết giờ — finalize + despawn")
	local resp = lib.callback.await(ResourceName .. ":rental:expireRental", false)
	lib.notify({
		title = "Thuê phương tiện",
		description = "Đã hết giờ thuê. Phương tiện bị thu hồi.",
		type = "error",
		duration = 6000,
	})
	self:ClearLocalRentalState()
	if resp and resp.data then
		SendNUIMessage({ action = "rental:impounded", data = { plate = resp.data.plate, receipt = resp.data } })
	end
end

function Impl:TickAbandonWatcher()
	if not activeRentalData then return end

	local ped = PlayerPedId()
	local playerIsDriver = false
	if activeRentalVehicle and DoesEntityExist(activeRentalVehicle) then
		playerIsDriver = GetPedInVehicleSeat(activeRentalVehicle, -1) == ped
	else
		activeRentalVehicle = nil
		local veh = GetVehiclePedIsIn(ped, false)
		if veh ~= 0 then
			local text = GetVehicleNumberPlateText(veh)
			if text and text:gsub("%s+", "") == activeRentalData.plate then
				SetEntityAsMissionEntity(veh, true, true)
				activeRentalVehicle = veh
				playerIsDriver = GetPedInVehicleSeat(veh, -1) == ped
			end
		end
	end

	if playerIsDriver then
		if abandonStartedAt then
			abandonStartedAt = nil
			self:ApplyCodemMainTimer()
		end
		return
	end

	local timeout = (Config.Rental.abandonTimeoutSeconds or 60) * 1000
	local nowMs = GetGameTimer()
	if not abandonStartedAt then
		abandonStartedAt = nowMs
		self:ApplyCodemAbandonTimer(timeout)
	else
		local elapsed = nowMs - abandonStartedAt
		if elapsed >= timeout then
			self:TriggerAbandonImpound()
		end
	end
end

function Impl:TriggerAbandonImpound()
	if not activeRentalData then return end
	self:LogInfo("Abandoned vehicle timed out — impounding")
	lib.notify({
		title = "Thuê phương tiện",
		description = "Phương tiện đã bị thu hồi vì bị bỏ lại.",
		type = "error",
		duration = 6000,
	})
	local resp = lib.callback.await(ResourceName .. ":rental:abandonRental", false)
	self:ClearLocalRentalState()
	if resp and resp.data then
		SendNUIMessage({ action = "rental:impounded", data = { plate = resp.data.plate, receipt = resp.data } })
	end
end

function Impl:GetCodemCfg()
	local data = activeRentalData
	if not data then return nil end
	local tbl = Config.Rental.codemEventTimer
	if not tbl then return nil end
	return tbl[data.category]
end

function Impl:HasCodem()
	return GetResourceState("codem-supreme-hud") == "started"
end

function Impl:ApplyCodemMainTimer()
	if not self:HasCodem() then return end
	local cfg = self:GetCodemCfg()
	if not cfg or not activeRentalData then return end
	self:RemoveCodemTimerById(self:GetAbandonCfgId())
	local iconUrl = nil
	local tpl = Config.Rental.vehicleIconUrlTemplate
	if tpl and activeRentalData.vehicleModel then
		iconUrl = string.format(tpl, activeRentalData.vehicleModel)
	end
	pcall(function()
		exports['codem-supreme-hud']:AddEventTimer({
			id = cfg.id,
			label = cfg.label,
			expiresAt = activeRentalData.expireAt,
			color = cfg.color,
			icon = cfg.icon,
			iconUrl = iconUrl,
		})
	end)
end

function Impl:ApplyCodemAbandonTimer(timeoutMs)
	if not self:HasCodem() then return end
	local cfg = Config.Rental.codemEventTimer and Config.Rental.codemEventTimer.abandonWarning
	if not cfg then return end
	local mainCfg = self:GetCodemCfg()
	if mainCfg then self:RemoveCodemTimerById(mainCfg.id) end
	pcall(function()
		exports['codem-supreme-hud']:AddEventTimer({
			id = cfg.id,
			label = cfg.label,
			duration = math.floor(timeoutMs / 1000),
			color = cfg.color,
			icon = cfg.icon,
		})
	end)
end

function Impl:GetAbandonCfgId()
	local cfg = Config.Rental.codemEventTimer and Config.Rental.codemEventTimer.abandonWarning
	return cfg and cfg.id or "gta5vn_rental_abandon"
end

function Impl:ClearCodemTimer()
	if not self:HasCodem() then return end
	local tbl = Config.Rental.codemEventTimer or {}
	for _, cfg in pairs(tbl) do
		if cfg.id then self:RemoveCodemTimerById(cfg.id) end
	end
end

function Impl:RemoveCodemTimerById(id)
	if not self:HasCodem() or not id then return end
	pcall(function()
		exports['codem-supreme-hud']:RemoveEventTimer(id)
	end)
end
