
-- Initialize Veriables
local round_status = 0 -- 0 = end, 0.9 = starting in 10s, 1 = active
local AmmoRegen = 0 -- Initialize regen counter variable

-- Pull ConVar Variables:
local infinite_round = GetConVar("q_infinite_round"):GetBool()
local round_length = 0
if not infinite_round then
    round_length = GetConVar("q_round_length"):GetFloat()
end

local more_nextbots = GetConVar("q_more_nextbots"):GetBool()
local obunga_delay = -1
if more_nextbots then
    obunga_delay = GetConVar("q_obunga_delay"):GetFloat()
end

util.AddNetworkString("UpdateRoundStatus")

-- Initiate Round:

function GM:ShowSpare1( ply )
    if round_status == 0 then
        preRound10( ply )
    elseif round_status == 0.9 then
        cancelPreRound( ply )
    else
        print("[OC] " .. ply:Nick() .. " attempted to start a round, but a round is already in progress.")
    end

end

-- Choose Player:
function GM:ShowSpare2( ply )
    if round_status == 0 then
        ply:ConCommand("playermodel_selector")
        print("[OC] " .. ply:Nick() .. " is attempting to change their player model.")
    else
        print("[OC] " .. ply:Nick() .. " attempted to change their player model while the round was in progress.")
    end

end

-- PreRound

function cancelPreRound( ply )
    timer.Remove( "preRound10Timer" )
    round_status = 0
    PrintMessage( 3 , "[OC] " .. ply:Nick() .. " canceled the round.")
end

function preRound10( ply )
    round_status = 0.9
    PrintMessage( 3 , "[OC] " .. ply:Nick() .. " started the round which will begin in 10 seconds.")
    local t = 10
    timer.Create("preRound10Timer", 1, t, function()
        t = t - 1

        -- Messages:
        if t == 3 or t == 2 or t == 1 then
            PrintMessage( 3 , "[OC] Game starting in " .. t)
        end

        if t == 0 then
            beginRound()
        end

    end)
end

-- Begin Round
function beginRound()

    if round_status == 0.9 then

        -- Round Status
        round_status = 1
        
        -- Give Loadout to New Players
        local ply = player.GetAll()
        for k, v in pairs(ply) do

            ply[k]:SetFrags( 0 )
            ply[k]:SetDeaths( 0 )

            Loadout(ply[k], 2)

        end

        -- Other Things Timer
        local t = 1 -- time counter variable
        local tspawn = 0
        timer.Create("RoundTimer", 1, round_length, function()

            -- Creates and obunga at every specific time using player spawn locations

            if tspawn == 0 or tspawn == obunga_delay then 
                local selectedBot = selectBot()
                local tempEnt = ents.Create(selectedBot)
                local spawns = ents.FindByClass("info_player_start")
                local random_spawn = math.random(#spawns)
                tempEnt:SetPos(spawns[random_spawn]:GetPos() + Vector(0,0,5))
                tempEnt:Spawn()
                print("[OC] Summoned ".. selectedBot)
                tspawn = 0
            end
            
            -- Ammo Regen:
            if AmmoRegen >= 3 then
                for k, v in pairs(ply) do
                    if ply[k]:Deaths() == 0 then
                        local AmmoCount = ply[k]:GetAmmoCount("Buckshot")
                        if AmmoCount < 6 then
                            ply[k]:GiveAmmo( 1 , "Buckshot", true)
                        end
                    end
                end
                AmmoRegen = 0 -- Reset Ammo Regen
            end
            AmmoRegen = AmmoRegen + 1

            -- Ends Round if Needed:

            if round_length == t then
                endRound()
            end

            tspawn = tspawn + 1
            t = t + 1
        end)

        -- Update Client Round Status
        updateClientRoundStatus()

        -- Message:
        PrintMessage(HUD_PRINTTALK, "[OC] Round Starting")
    else
        print("[OC] Attempted to start round but round is already in progress (see beginRound())")
    end

end

-- Loadouts:
function Loadout( ply, kit )

    -- General:
    ply:SetRunSpeed( 640 )
    ply:SetMaxSpeed( 700 )
    ply:SetWalkSpeed( 400 )
    ply:RemoveAllItems()

    -- Specific
    if kit == 1 then
        -- Atributes:
        ply:SetHealth( ply:GetMaxHealth() )
        ply:SetModel("models/kaydax/gman_obunga.mdl")

        -- Loadout:
        ply:Give("weapon_crowbar")
        ply:CanUseFlashlight( true )
        ply:AllowFlashlight( true )

        print( "[OC] ".. ply:Nick() .. " has been given the Obunga loadout!" ) 
    elseif kit == 2 then
        -- Atributes:
        ply:SetHealth( 2*ply:GetMaxHealth() )

        -- Loadout
        ply:Give("weapon_shotgun")
        ply:Give("weapon_fists")
        ply:CanUseFlashlight( true ) 
        ply:AllowFlashlight( true )

        print( "[OC] ".. ply:Nick() .. " has been given the Runner loadout!" )
    elseif kit == 3 then
        ply:SetModel("models/player/leet.mdl")
        ply:CanUseFlashlight( true )
        ply:AllowFlashlight( true )
        print( "[OC] ".. ply:Nick() .. " has been given the Waiting loadout!" )
    end 

end

-- Player Spawn Hook:
local function Respawn( ply )

    if round_status == 1 then
        Loadout(ply, 1)
    else
        Loadout(ply, 3)
    end

end
hook.Add( "PlayerSpawn", "Respawn", Respawn)

-- Look to End Round Hook:
-- If round is over, ensure that obungas are gone and timer is removed
local function checkRoundOver()
    if round_status == 1 then
        local Alive = 0
        local playernum = 0
        local ply = player.GetAll()
        for k, v in pairs(ply) do
            if ply[k]:Deaths() == 0 then
                Alive = Alive + 1
            end
            playernum = playernum + 1 -- Counts number of Players
        end

        -- If number of players is more than 1
        if Alive <= 1 and playernum > 1 then
            endRound()
        end

        -- If number of players is less than 1
        if Alive < 1 and playernum == 1 then
            endRound()
        end
    elseif round_status == 0 then
        -- Remove Timer:
        timer.Remove( "RoundTimer" )
        
        -- Remove All Nextbots

        for k, v in pairs(getActiveNextbots()) do
            local nextbots = ents.FindByClass( v )

            for k2, v2 in pairs(nextbots) do 
                nextbots[k2]:Remove()
            end
        end
    end
end
hook.Add( "Think" , "checkRoundOver", checkRoundOver)

-- End Round:
function endRound()

    -- Set Round Status
    round_status = 0

    -- Remove Timer:
    timer.Remove( "RoundTimer" )
    
    -- Remove All Nextbots

    for k, v in pairs(getActiveNextbots()) do
        local nextbots = ents.FindByClass( v )

        for k2, v2 in pairs(nextbots) do 
            nextbots[k2]:Remove()
        end
    end

    -- Update Client of the Round Status
    updateClientRoundStatus()
    
    -- Winner Messages and Loadout:
    local ply = player.GetAll()
    local playernum = 0
    local winners = 0
    for k, v in pairs(ply) do

        Loadout( ply[k], 3)
        playernum = playernum + 1

        if ply[k]:Deaths() == 0 then
            PrintMessage(HUD_PRINTTALK, "[OC] "..ply[k]:Nick().." is a winner!")
            winners = winners + 1
        end
    end

    if winners == 0 and playernum == 1 then
        PrintMessage(HUD_PRINTTALK, "[OC] Get 'bungad")
    end

    if winners == 0 and playernum > 1 then
        PrintMessage(HUD_PRINTTALK, "[OC] Obunga Wins!")
    end
    
    -- Obunga with most kills:
    local maxkills = 0
    for k, v in pairs(ply) do
        if ply[k]:Deaths() > 0 and ply[k]:Frags() > maxkills then
            maxkills = ply[k]:Frags()
        end
    end

    if maxkills > 0 then
        for k, v in pairs(ply) do
            if ply[k]:Deaths() > 0 and maxkills == ply[k]:Frags() then
                PrintMessage(HUD_PRINTTALK, "[OC]"..ply[k]:Nick().." had the most kills (".. maxkills .. ") as an obunga!")
            end
        end
    end

    -- Message:
    PrintMessage(HUD_PRINTTALK, "[OC] Round Over")

end

function getRoundStatus()

    return round_status

end

function updateClientRoundStatus()

    net.Start("UpdateRoundStatus")
        net.WriteInt(round_status,4)
    net.Broadcast()

end