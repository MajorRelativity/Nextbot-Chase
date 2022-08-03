local round_status = 0 -- 0 = end, 1 = active

util.AddNetworkString("UpdateRoundStatus")

function beginRound()

    round_status = 1
    updateClientRoundStatus()

end

function endRound()

    round_status = 0
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