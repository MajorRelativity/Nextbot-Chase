local round_status = 0 -- 0 = end, 1 = active
local t = 1 -- time counter variable
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
        print(ply)
        for k, v in pairs(ply) do
            ply[k]:Give("weapon_stunstick")
        end

        -- Other Things Timer
        timer.Create("RoundTimer", 1, round_length, function()

            -- Creates and obunga at every specific time using player spawn locations
            if (t == 1 or t == 20) then 
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
    end

end

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

end

function getRoundStatus()

    return round_status

end

function updateClientRoundStatus()

    net.Start("UpdateRoundStatus")
        net.WriteInt(round_status,4)
    net.Broadcast()

end