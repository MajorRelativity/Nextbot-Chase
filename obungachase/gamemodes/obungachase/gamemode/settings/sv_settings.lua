

-- Choose Nextbots:

local Nextbots = {"npc_obunga","npc_therock"}
local NextbotsOn = {GetConVar("q_npc_obunga"):GetBool(),GetConVar("q_npc_therock"):GetBool()}
local customBot = GetConVar("q_npc_custom"):GetString()
if customBot == GetConVar("q_npc_custom"):GetDefault() then
    customBot = 0
end

function getActiveNextbots()
    -- Load Counter Variable:
    local c = 1
    local sNextbots = {}

    -- Apply Custom bot:
    if customBot ~= 0 then
        sNextbots[c] = customBot
        c = c + 1
    end

    -- Find Hard Programed Bots that are On
    for k, v in pairs(Nextbots) do
        if NextbotsOn[k] then
            sNextbots[c] = v
            c = c + 1
        end
    end

    return sNextbots
end

function selectBot()
    
    sNextbots = getActiveNextbots()

    -- Decide Random Bot
    selectedBot = sNextbots[math.random(1, #sNextbots)]
    return selectedBot
    
end
