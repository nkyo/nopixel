endResult = {}

function FindEndPoint()
    local raceend = {}
    raceend["x"] = 0.0
    raceend["y"] = 0.0
    raceend["z"] = 30.0
    Citizen.Trace("Search endpoint coords: " .. raceend["x"] .. "," .. raceend["y"] .. "," .. raceend["z"])
    raceend["x"] = math.random(-3000,3000) + 1.0  
    raceend["y"] = math.random(-1000,6500) + 1.0  
    Citizen.Trace("Search endpoint coords 2: " .. raceend["x"] .. "," .. raceend["y"] .. "," .. raceend["z"])
    roadtest, endResult, outHeading = GetClosestVehicleNode(raceend["x"], raceend["y"], raceend["z"],  0, 999.9, 999.9)
    Citizen.Trace("Found endpoint coords: " .. endResult["x"] .. "," .. endResult["y"] .. "," .. endResult["z"])
    return endResult["x"], endResult["y"], endResult["z"]
    --endResult["x"], endResult["y"], endResult["z"]
end



function DrawText3DTest(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)

end



function resetRaceVars()
    requesting = false
    inrace = false
    racing = false
end

RegisterNetEvent("race:accepted")
AddEventHandler("race:accepted", function()
    requesting = true
    inrace = true
    racing = true
    TriggerEvent("DoLongHudText","Accepted into race, please wait.",1)
end)

RegisterNetEvent("race:declined")
AddEventHandler("race:declined", function()
    resetRaceVars()
    TriggerEvent("DoLongHudText","You must own the vehicle.",2)
end)

inrace = false
RegisterNetEvent("race:eventStarting")
AddEventHandler("race:eventStarting", function(x,y,z,cost,posx,posy,posz)

    local raceDistance = #(vector3(posx,posy,posz) - GetEntityCoords(PlayerPedId()))
    if raceDistance < 100.0 then
        local timer = 3500
        while timer > 0 do
            raceDistance = #(vector3(posx,posy,posz) - GetEntityCoords(PlayerPedId()))
            timer = timer - 1
            if raceDistance < 20.0 then
                if not inrace then
                    DrawText3DTest(posx,posy,posz, "Press [E] to join this race - the current cost is: " .. cost )
                else
                    if racing and raceactive then
                        DrawText3DTest(posx,posy,posz, "GO GO GO!." )
                    else
                        DrawText3DTest(posx,posy,posz, "Race Starting Shortly - do not move too far.")
                    end                    
                end
                if IsControlJustReleased(1,38) and not inrace then
                    local playerPed = PlayerPedId()
                    local currentVehicle = GetVehiclePedIsIn(playerPed, false)
                    local driverPed = GetPedInVehicleSeat(currentVehicle, -1)

                    if currentVehicle ~= nil and currentVehicle ~= false and currentVehicle ~= 0 then
                        if driverPed == PlayerPedId() then
                            licensePlate = GetVehicleNumberPlateText(currentVehicle)
                            TriggerServerEvent("race:joinrace",licensePlate)
                            TriggerEvent("DoLongHudText","Attempting to join race.",1)
                        end
                    end
                    Citizen.Wait(1000)
                end
            else
                if inrace then
                    if racing and raceactive then
                        DrawText3DTest(posx,posy,posz, "GO GO GO!." )
                    else
                        DrawText3DTest(posx,posy,posz, "You are too far from the race begin point, you will lose your bet." )
                    end
                else
                    DrawText3DTest(posx,posy,posz, "A race is happening in this location - the current cost is: " .. cost )
                end
            end
            Citizen.Wait(1)
        end
    end
end)
local raceactive = false

RegisterNetEvent("race:confirmedStart")
AddEventHandler("race:confirmedStart", function(x,y,z,cost,posx,posy,posz)
    if inrace then
        raceactive = true
        TriggerEvent("DoLongHudText","Race Starts in 3",14)
        PlaySound(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
        Citizen.Wait(1000)
        TriggerEvent("DoLongHudText","Race Starts in 2",14)
        PlaySound(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
        Citizen.Wait(1000)
        TriggerEvent("DoLongHudText","Race Starts in 1",14)
        PlaySound(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
        Citizen.Wait(1000)
        PlaySound(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
        TriggerEvent("DoLongHudText","GO!",14)
        raceDistance = #(vector3(posx,posy,posz) - GetEntityCoords(PlayerPedId()))
        if raceDistance > 25.0 then
                TriggerEvent("DoLongHudText","You were disqualified")
            return
        end
        endResult = {}
        endResult["x"] = x
        endResult["y"] = y
        endResult["z"] = z
        SetNewWaypoint(x,y)
        TriggerEvent("race:begin")
    end
end)


RegisterNetEvent("race:50")
AddEventHandler("race:50", function()
    TriggerEvent("race:requestStart",1)
end)

RegisterNetEvent("race:500")
AddEventHandler("race:500", function()   
    TriggerEvent("race:requestStart",2)
end)

RegisterNetEvent("race:5000")
AddEventHandler("race:5000", function()    
    TriggerEvent("race:requestStart",3)
end)

RegisterNetEvent("race:50000")
AddEventHandler("race:50000", function()    
    TriggerEvent("race:requestStart",4)
end)

RegisterNetEvent("race:pinkslips")
AddEventHandler("race:pinkslips", function()    
    TriggerEvent("race:requestStart",5)
end)


requesting = false

function FindEndPointCar2(x,y) 

    local randomPool = 10.0
    local tryneg = false
    while true do
        if (randomPool > 2900) then
            randomPool = 50.0
            tryneg = true
        end
        local vehSpawnResult = {}
        if tryneg then
        vehSpawnResult["x"] = x-randomPool
        vehSpawnResult["y"] = y-randomPool
        else
        vehSpawnResult["x"] = x+randomPool
        vehSpawnResult["y"] = y+randomPool
        end

        vehSpawnResult["z"] = 0.0

        roadtest, vehSpawnResult, outHeading = GetClosestVehicleNode(vehSpawnResult["x"], vehSpawnResult["y"], vehSpawnResult["z"],  1, 999.0, 999.0)

        Citizen.Wait(1000)   

        if vehSpawnResult["z"] ~= 0.0 then
            local caisseo = GetClosestVehicle(vehSpawnResult["x"], vehSpawnResult["y"], vehSpawnResult["z"], 20.000, 0, 70)
            if not DoesEntityExist(caisseo) then
 
                return vehSpawnResult["x"], vehSpawnResult["y"], vehSpawnResult["z"], outHeading
            end
            
        end


        randomPool = randomPool + 10.0
    end

    --endResult["x"], endResult["y"], endResult["z"]

end


RegisterNetEvent("race:requestStart")
AddEventHandler("race:requestStart", function(cost,custom)

    local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if currentVehicle == 0 then
        TriggerEvent("DoLongHudText","no vehicle",1)
        return
    end

    if not requesting and not racing then

        if tonumber(custom) == 1 then

            local Waypoint = GetFirstBlipInfoId(8)
            
            if Waypoint == 0 then
                TriggerEvent("DoLongHudText","Please place a marker on the map.",1)
                return
            end

            local StoredCoord = Citizen.InvokeNative(0xFA7C7F0AADF25D09, Waypoint, Citizen.ResultAsVector())  

            endResult["x"], endResult["y"], endResult["z"], outHeading = FindEndPointCar2(StoredCoord["x"],StoredCoord["y"])

        else
            requesting = true
            local dicks = true

            while dicks do
                endResult = {}
                endResult["x"], endResult["y"], endResult["z"] = FindEndPoint()
                Citizen.Wait(10)
                if endResult["z"] ~= 0.0 then
                    dicks = false
                end
            end
        end

        local pos = GetEntityCoords(PlayerPedId())
        TriggerEvent("DoLongHudText","Race will begin in 30 seconds",14)
        TriggerServerEvent("race:eventStarting",endResult["x"], endResult["y"], endResult["z"],cost,pos["x"], pos["y"], pos["z"])

    else

        TriggerEvent("DoLongHudText","You are already in a vehicle race.",1)

    end
     
end)

racing = false

RegisterNetEvent("race:end")
AddEventHandler("race:end", function()
    if inrace or racing or requesting then
        resetRaceVars()
        Citizen.Trace("A race has been forced to end (looks like we lost)!")
        PlaySound(-1, "LOSER", "HUD_AWARDS", 0, 0, 1)
    end
end)

RegisterNetEvent("race:beginServer")
AddEventHandler("race:beginServer", function(serverResult)
    endResult = serverResult
    SetNewWaypoint(endResult["x"], endResult["y"])
    TriggerEvent("race:begin") 
end)

RegisterNetEvent("race:begin")
AddEventHandler("race:begin", function()

    racing = true
    local endDistance = 999.9
    local winner = false
    Citizen.Trace("A race has started!")
    while racing and not winner do
        Citizen.Wait(5)
        endDistance = #(vector3(endResult["x"], endResult["y"], endResult["z"]) - GetEntityCoords(PlayerPedId())) 
        if endDistance < 10.0 then
            winner = true
        end
        DrawText3DTest(endResult["x"], endResult["y"], endResult["z"], "Race End" )
    end

    if winner then
        Citizen.Trace("You won the race!")
        PlaySound(-1, "FIRST_PLACE", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
        TriggerServerEvent("race:completed")
    end
    raceactive = false
    requesting = false
    endResult = {}
end)