-- Settings
local color = { r = 50, g = 50, b = 50, alpha = 255 } -- Color of the text 
local font = 0 -- Font of the text
local time = 7000 -- Duration of the display of the text : 1000ms = 1sec
local background = {
    enable = true,
    color = { r = 20, g = 20, b = 20, alpha = 255 },
}

-- distance squared to calculate against Vdist2()
local dispRadius2 = 7*7
local chatMessage = false
local dropShadow = true
local displaying = false

local game = { }

-- Don't touch
local nbrDisplaying = 1


RegisterNetEvent('casino:gamePayout')
AddEventHandler('casino:gamePayout',function(amount)
end)

RegisterNetEvent('casino:clearDisplay')
AddEventHandler('casino:clearDisplay',function(g)
    if g == 'all' then
        for i, disp in ipairs(game) do
            disp['displaying'] = false
        end
    else
        game[g]['displaying'] = false
    end
    -- Wait(1000)
end)

-- Displays info on game location/coordinates. 
RegisterNetEvent('casino:triggerDisplay')
AddEventHandler('casino:triggerDisplay', function(text, entity, duration, gameId, color)
    if not game[gameId] then
        game[gameId] = {}
    end
    local offset = 0 + (nbrDisplaying*0.14)
    game[gameId]['text'] =  text
    if color ~= nil then    
        game[gameId]['color'] = color
    end
    if not game[gameId]['displaying'] then
        gameIdGameDisplay(entity, game[gameId]['text'], duration, offset, gameId)
    end
end)

function gameIdGameDisplay(entity, text, duration, offset, gameId)
    local anchor
    local time = duration
    game[gameId]['displaying'] = true

    Citizen.CreateThread(function()
        Wait(time) 
        if time > 0 then
            game[gameId]['displaying'] = false
        end

    end)

    Citizen.CreateThread(function()
        nbrDisplaying = nbrDisplaying + 1
        while game[gameId]['displaying'] do
            local coords = GetEntityCoords(PlayerPedId(), false)
            
            local dist2 = Vdist2(entity, coords)
            if dist2 < dispRadius2 then
                DrawText3D(entity['x'], entity['y'], entity['z']+offset, game[gameId]['text'], game[gameId]['color'])
            end
            Wait(0)
        end
        nbrDisplaying = nbrDisplaying - 1
    end)
end

function DrawText3D(x,y,z, text, color)
    -- local color = color or { r = 220, g = 220, b = 220, alpha = 255 } -- Color of the text 
    -- local color = color or { r = 220, g = 220, b = 220, alpha = 255 } -- Color of the text 
    local onScreen,_x,_y = World3dToScreen2d(x,y,z)
    local px,py,pz = table.unpack(GetGameplayCamCoord())
    local dist = #(vector3(px,py,pz) - vector3(x,y,z))
 
    local scale = ((1/dist)*2)*(1/GetGameplayCamFov())*55

    if onScreen then

        -- Formalize the text
        SetTextColour(color.r, color.g, color.b, color.alpha)
        SetTextScale(0.0*scale, 0.50*scale)
        SetTextFont(font)
        -- SetTextProportional(1)
        SetTextCentre(true)
        SetTextDropshadow(1, 0, 0, 0, 255)
        if dropShadow then
        end
        -- Diplay the text
        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)
        
        -- Calculate width and height
        BeginTextCommandWidth("STRING")
        local height = GetTextScaleHeight(1*scale, font)
        local width = EndTextCommandGetWidth(text)
        local length = string.len(text)
        local factor = (length * .005) + .05
        if background.enable then
            DrawRect(_x, _y+scale/45, (factor *scale) + .001, height, background.color.r, background.color.g, background.color.b , background.color.alpha)
        end
    end
end
