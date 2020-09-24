local BlipHandlers = {}

Citizen.CreateThread(function()
	while true do
		if NetworkIsSessionStarted() then
			DecorRegister("EmergencyType", 3)
			DecorSetInt(PlayerPedId(), "EmergencyType", 0)
			return
		end
	end
end)

--[[
	Emergency Type Decor:
		1 = police
		2 = ems
]]

RegisterNetEvent("np-jobmanager:playerBecameJob")
AddEventHandler("np-jobmanager:playerBecameJob", function(job, name, notify)
	if job == "police" then
		DecorSetInt(PlayerPedId(), "EmergencyType", 1)
	elseif job == "ems" then
		DecorSetInt(PlayerPedId(), "EmergencyType", 2)
	else
		DecorSetInt(PlayerPedId(), "EmergencyType", 0)
	end
end)


RegisterNetEvent("e-blips:updateAfterPedChange")
AddEventHandler("e-blips:updateAfterPedChange", function(job)
	if job == "police" then
		DecorSetInt(PlayerPedId(), "EmergencyType", 1)
	elseif job == "ems" then
		DecorSetInt(PlayerPedId(), "EmergencyType", 2)
	else
		DecorSetInt(PlayerPedId(), "EmergencyType", 0)
	end
end)

local function setDecor()
	local type = 0
	
	TriggerEvent("nowIsCop", function(_isCop)
		TriggerEvent("nowIsEMS", function(_isMedic)
			type = _isCop and 1 or 0
			type = (type == 0 and _isMedic) and 2 or type
			DecorSetInt(PlayerPedId(), "EmergencyType", type)
		end)
	end)
end


local lastLocations = {}

local SlowStacks = {}


function LastLocationBlip(ped,id) 
	local x,y,z = table.unpack(GetEntityCoords(ped))
  	local blip = AddBlipForCoord(x, y, z)
  	lastLocations[id] = blip

end

function GetBlipSettings(ped)
	local settings = {}

	settings.short = true
	settings.sprite = 1

	if DecorGetInt(ped, "EmergencyType") == 1 then
		settings.color = 3
		settings.heading =  true
		settings.text = 'Officer'
	end

	if DecorGetInt(ped, "EmergencyType") == 2 then
		settings.color = 23
		settings.heading =  true
		settings.text = 'Paramedic'
	end

	return settings
end

function StandardBlip(ped,id) 


	blip = AddBlipForEntity(ped)
	SetBlipAsShortRange(blip, true)
	SetBlipSprite(blip, 1)


	if DecorGetInt(ped, "EmergencyType") == 1 then
		SetBlipColour(blip, 3)
		ShowHeadingIndicatorOnBlip(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Officer")
	end

	if DecorGetInt(ped, "EmergencyType") == 2 then
		SetBlipColour(blip, 23)
		ShowHeadingIndicatorOnBlip(blip, true)
		BeginTextCommandSetBlipName("STRING")		
		AddTextComponentString("Paramedic")
	end
	
	EndTextCommandSetBlipName(blip)
end

Citizen.CreateThread(function()
	local function createBlip(id)

		local ped = GetPlayerPed(id)
		local localped = PlayerPedId()
		local blip = GetBlipFromEntity(ped)
		
		if not DecorExistOn(ped, "EmergencyType") then return end
		if not DecorExistOn(localped, "EmergencyType") then return end

		local blipExist = DoesBlipExist(blip)

		if blipExist and DecorGetInt(ped, "EmergencyType") <= 0 then RemoveBlip(blip) return end
		if blipExist and DecorGetInt(localped, "EmergencyType") <= 0 then RemoveBlip(blip) return end

		if DecorGetInt(ped, "EmergencyType") <= 0 or DecorGetInt(localped, "EmergencyType") <= 0 then return end

		if blipExist then return end
		
		StandardBlip(ped,id) 

	end

	local function deleteBlipHandler(serverId)
		local handler = BlipHandlers[serverId]

		if handler then
			handler:disable()
		end

		BlipHandlers[serverId] = nil
	end

	local function createBlipHanlder(id)
		local ped = GetPlayerPed(id)
		local localped = PlayerPedId()
		
		if not DecorExistOn(ped, "EmergencyType") then return end
		if not DecorExistOn(localped, "EmergencyType") then return end
		
		local serverId = GetPlayerServerId(id)
		
		local handlerExist = BlipHandlers[serverId] ~= nil
		
		if handlerExist and DecorGetInt(ped, "EmergencyType") <= 0 then deleteBlipHandler(serverId) return end
		if handlerExist and DecorGetInt(localped, "EmergencyType") <= 0 then deleteBlipHandler(serverId) return end
		
		if DecorGetInt(ped, "EmergencyType") <= 0 or DecorGetInt(localped, "EmergencyType") <= 0 then return end
		
		if handlerExist then return end
		
		local settings = GetBlipSettings(ped)
		
		BlipHandlers[serverId] = EntityBlip:new('player', serverId, settings)
		
		BlipHandlers[serverId]:enable()
	end

	while true do

		Citizen.Wait(2000)

		if not DecorExistOn(PlayerPedId(), "EmergencyType") then setDecor() end -- Decors don't stick with players when their ped changes, currently only works with police.

		for id = 0, 256 do

			if NetworkIsPlayerActive(id) then

				createBlipHanlder(id)

			end

		end

	end

end)