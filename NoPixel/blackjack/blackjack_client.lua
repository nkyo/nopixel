local waitingToJoin = {}
local maxBet = {}
local defaultMax = 1000
local interactDistance = 3
local spectatorDistance = 20
local joinGame = {}
local chips = {}

RegisterNetEvent('blackjack:setMaxBet')
AddEventHandler('blackjack:setMaxBet',function(gameNumber, bet)
    maxBet[gameNumber] = tonumber(bet)
end)

RegisterNetEvent('blackjack:leaveAll')
AddEventHandler('blackjack:leaveAll',function()
    for i, game in pairs(joinGame) do
        joinGame[i] = false
    end
    for j, join in pairs(waitingToJoin) do
        waitingToJoin[j] = false
    end 
    TriggerEvent('casino:clearDisplay','all')
    TriggerServerEvent('casinoPlayer:clear','all','all')
end)

RegisterNetEvent('blackjack:updateChips')
AddEventHandler('blackjack:updateChips',function(gameNumber)
    chips[tonumber(gameNumber)] = exports["pitboss"]:getChipBalance(tostring(gameNumber))
    if chips[tonumber(gameNumber)] then
        chips[tonumber(gameNumber)] = math.floor(chips[tonumber(gameNumber)])
    else
        chips[tonumber(gameNumber)] = 0
    end
end)


RegisterNetEvent('blackjack:OpenTable')
AddEventHandler('blackjack:OpenTable',function(gameNumber, table, options)
    if options["useChips"] then
        TriggerEvent('blackjack:updateChips',gameNumber)
        
    end
    Wait(100)
    if not maxBet[gameNumber] then maxBet[gameNumber] = defaultMax end
    joinGame[gameNumber] = false
    local tableCoords = table
    local playerCoords = GetEntityCoords(PlayerPedId())
    local betSubmitted = false
    local bet = 0
    
    -- Only open table for nearby players, only start while loop for non-nearby players
    if Vdist(tableCoords,playerCoords) < (spectatorDistance) then
        waitingToJoin[gameNumber] = true
    end

    while waitingToJoin[gameNumber] do
        playerCoords = GetEntityCoords(PlayerPedId())
        local distance = Vdist(tableCoords,playerCoords)
        -- if player moves too far, end while loop
        if distance > (spectatorDistance) then
            waitingToJoin[gameNumber] = false
            joinGame[gameNumber] = false
        end
        if distance < interactDistance then
        
            -- Do not allow $0 bet
            if IsControlJustPressed(0,46) and (bet > 0) then -- Key: E
                SendNUIMessage({
                    type = 'CASINO_MESSAGE',
                    message = "[Backspace] to withdraw bet"
                })
                joinGame[gameNumber] = true
                local text = 'P' .. GetPlayerServerId(PlayerId()) .. ': Betting $' .. bet
                local hudConfig = {}
                hudConfig['text'] = text
                hudConfig['duration'] = -1
                hudConfig['gameNumber'] = gameNumber
                hudConfig['netId'] = GetPlayerServerId(PlayerId())
                -- Display bet to all
                TriggerServerEvent('casinoPlayer:shareDisplay', -1, hudConfig)
                betSubmitted = true
                

                Wait(10)
            end
            if IsControlJustPressed(0,177) and betSubmitted then -- Key: Backspace
                joinGame[gameNumber] = false
                local text = 'Bet withdrawn'
                local hudConfig = {}
                hudConfig['text'] = text
                hudConfig['duration'] = -1
                hudConfig['gameNumber'] = gameNumber
                hudConfig['netId'] = GetPlayerServerId(PlayerId())
                -- Display bet to all
                TriggerServerEvent('casinoPlayer:shareDisplay', -1, hudConfig)
                betSubmitted = false
                Wait(10)
            end
            if IsControlJustPressed(0,83) and not betSubmitted then -- Key: +
                bet = bet + 50
                -- only allow max bet of what player currently has
                if bet > maxBet[gameNumber] then bet = maxBet[gameNumber] end
                if options["useChips"] then
                    if chips[gameNumber] > 0 and (bet > chips[gameNumber]) then 
                        bet = chips[gameNumber]
                    elseif bet > chips[gameNumber] then
                        bet = 0 
                    end
                end
                local text = '$' .. bet .. ' | [E] Submit'
                local hudConfig = {}
                hudConfig['text'] = text
                hudConfig['duration'] = -1
                hudConfig['gameNumber'] = gameNumber
                hudConfig['netId'] = GetPlayerServerId(PlayerId())
                -- Display current bet amount to player only
                TriggerServerEvent('casinoPlayer:shareDisplay', GetPlayerServerId(PlayerId()), hudConfig)
                Wait(10)
            end
            if IsControlJustPressed(0,84) and not betSubmitted  then -- Key: -
                bet = bet - 50
                -- do not allow negative bet
                if bet < 0 then bet = 0 end
                local text = '$' .. bet .. ' | [E] Submit'
                local hudConfig = {}
                hudConfig['text'] = text
                hudConfig['duration'] = -1
                hudConfig['gameNumber'] = gameNumber
                hudConfig['netId'] = GetPlayerServerId(PlayerId())
                -- Display current bet amount to player only
                TriggerServerEvent('casinoPlayer:shareDisplay', GetPlayerServerId(PlayerId()), hudConfig)
                Wait(10)
            end
        
        end
        Wait(0)
    end
    playerCoords = GetEntityCoords(PlayerPedId())

    if Vdist(tableCoords,playerCoords) > interactDistance then
        joinGame[gameNumber] = false
    end
    if joinGame[gameNumber] then
        TriggerServerEvent('blackjack:JoinTable', gameNumber, bet)
    else 
        -- If player never submits bet or goes too far, clear "betting" display
        waitingToJoin[gameNumber] = false
        TriggerServerEvent('casinoPlayer:clear',gameNumber, GetPlayerServerId(PlayerId()))
    end

    -- waitingToJoin[gameNumber] = true
    joinGame[gameNumber] = false

end)


-- Clears all player HUDs and ends joining game loop
-- RegisterCommand('casinoclearhud', function(source,args)
--     for i, game in pairs(joinGame) do
--         -- joinGame[gameNumber] = false
--         game = false
--         TriggerEvent('casinoPlayer:clearDisplay', k, 'all')
--     end
--     Wait(100)
--     for k, game in pairs(waitingToJoin) do
--         game = false
--         TriggerEvent('casinoPlayer:clearDisplay', k, 'all')
--     end
-- end)

RegisterNetEvent('blackjack:betsClosed')
AddEventHandler('blackjack:betsClosed',function(gameNumber)
    -- Close bets for dealer's table
    waitingToJoin[gameNumber] = false
    -- Wait(500)
    -- waitingToJoin[gameNumber] = {}
end)
RegisterNetEvent('blackjack:kicked')
AddEventHandler('blackjack:kicked',function(gameNumber)
    joinGame[gameNumber] = false
    Wait(100)
    waitingToJoin[gameNumber] = false
end)