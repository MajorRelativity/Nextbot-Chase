local round_status = 0 -- 0 = end, 1 = active
local round_length = 40-- Seconds

util.AddNetworkString("UpdateRoundStatus")

-- Begin Round
function beginRound()

    if round_status == 0 then

        -- Round Status
        round_status = 1

        -- End Round Timer
        timer.Simple(round_length, function()
        endRound()
        end) 
        
        -- Give Loadout to New Players
        local ply = player.GetAll()
        print(ply[1]:Deaths())
        for k, v in pairs(ply) do
            ply[k]:RemoveAllItems()

            ply[k]:Give("weapon_stunstick")
            ply[k]:SetDeaths( 0 )
            ply[k]:SetModel("models/player/gman_high.mdl")
        end

        -- Other Things Timer
        local t = 1 -- time counter variable
        timer.Create("RoundTimer", 1, round_length, function()

            -- Creates and obunga at every specific time using player spawn locations
            local ts1 = math.Round( 1*round_length/4) -- Spawn Times
            local ts2 = math.Round( 2*round_length/4)
            local ts3 = math.Round( 3*round_length/4)

            if (t == 1 or t == ts1 or t == ts2 or t == ts3) then 
                local tempObunga = ents.Create("npc_obunga")
                local spawns = ents.FindByClass("info_player_start")
                local random_spawn = math.random(#spawns)
                tempObunga:SetPos(spawns[random_spawn]:GetPos() + Vector(0,0,5))
                tempObunga:Spawn()
                print("[OC] Summoned Obunga")
            end
            t = t + 1
        end)

        -- Update Client Round Status
        updateClientRoundStatus()

        -- Message:
        PrintMessage(HUD_PRINTTALK, "[OC] Round Starting")
    end

end

-- Player Spawn Hook:
local function Respawn( ply )
    if ply:Deaths() > 0 then
        ply:Give("weapon_crowbar")
        ply:SetModel("models/kaydax/gman_obunga.mdl")
	    print( "[OC] ".. ply:Nick() .. " has respawned as an Obunga!" )
    end
end
hook.Add( "PlayerSpawn", "Respawn", Respawn)

-- End Round:
function endRound()

    -- Set Round Status
    round_status = 0
    
    -- Remove All Obungas
    obungas = ents.FindByClass( "npc_obunga" )

    for k, v in pairs(obungas) do 
        obungas[k]:Remove()
    end

    -- Update Client of the Round Status
    updateClientRoundStatus()
    
    -- Winner Messages:
    local ply = player.GetAll()
    for k, v in pairs(ply) do

        if ply[k]:Deaths() == 0 then
            PrintMessage(HUD_PRINTTALK, "[OC] "..ply[k]:Nick().." is a winner!")
        end
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
            if maxkills == ply[k]:Frags() then
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