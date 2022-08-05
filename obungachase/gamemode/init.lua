-- Base Files:
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Include Other Scripts:
AddCSLuaFile("round_controller/cl_round_controller.lua")
include("round_controller/sv_round_controller.lua")

include("shared.lua")

function GM:PlayerConnect(name, ip)

    print("[OC] Player "..name.." connected with IP ("..ip..")")

end

function GM:PlayerInitialSpawn(ply)

    print("[OC] Player "..ply:Name().." has spawned")

end