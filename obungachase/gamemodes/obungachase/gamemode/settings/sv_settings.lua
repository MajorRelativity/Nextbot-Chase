

-- Choose Nextbots:

local Nextbots = {"npc_obunga","npc_therock"}
local NextbotsOn = {GetConVar("q_npc_obunga"):GetBool(),GetConVar("q_npc_therock"):GetBool()}
local customBot = GetConVar("q_npc_custom"):GetString()
local customBot2 = GetConVar("q_npc_custom2"):GetString()
local customBot3 = GetConVar("q_npc_custom3"):GetString()
local customBot4 = GetConVar("q_npc_custom4"):GetString()
local customBot5 = GetConVar("q_npc_custom5"):GetString()
if customBot == GetConVar("q_npc_custom"):GetDefault() then
    customBot = 0
end
if customBot2 == GetConVar("q_npc_custom2"):GetDefault() then
    customBot2 = 0
end
if customBot3 == GetConVar("q_npc_custom3"):GetDefault() then
    customBot3 = 0
end
if customBot4 == GetConVar("q_npc_custom4"):GetDefault() then
    customBot4 = 0
end
if customBot5 == GetConVar("q_npc_custom5"):GetDefault() then
    customBot5 = 0
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
    if customBot2 ~= 0 then
        sNextbots[c] = customBot2
        c = c + 1
    end
    if customBot3 ~= 0 then
        sNextbots[c] = customBot3
        c = c + 1
    end
    if customBot4 ~= 0 then
        sNextbots[c] = customBot4
        c = c + 1
    end
    if customBot5 ~= 0 then
        sNextbots[c] = customBot5
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
