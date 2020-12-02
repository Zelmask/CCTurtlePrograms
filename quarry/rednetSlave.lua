local MASTER = 0
local SLAVE = 1

local idsToSendTo = {...}

function broadcast(s)
	rednet.broadcast(s)
end

function reset