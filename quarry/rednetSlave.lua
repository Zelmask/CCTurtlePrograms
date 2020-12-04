os.loadAPI("rednetCommon.lua")
local MasterCallback
local idHost

local function toCallback(command,id,msg)
    if command == rednetCommon.getCommandPrefix()["STATUS"] then
        print(textutils.formatTime(os.time(), true) .. " - " .. tostring(id) .. " - " .. msg)
    elseif command == rednetCommon.getCommandPrefix()["ACTION"] then
		if MasterCallback~=nil then
			MasterCallback(command,id,msg)
        end
    else
        print("Unhandled command " .. command .. " received from " .. id)
    end
end

function work(pProtocol,pHostname,pCallback)
	idHost = findHost(pProtocol,pHostname)
	if idHost~=nil then
		MasterCallback = pCallback
		return rednetCommon.initialize(pProtocol,toCallback)
	end
	return {}
end

function findHost(pProtocol,pHostname)
    if rednetCommon.initiateModem() then
        local foundHost = false
		while not foundHost do
			print("Looking for host : " .. pHostname)
			local workIdHost = rednet.lookup(pProtocol,pHostname)
			if workIdHost ~= nil then
				print("Found Host : " .. workIdHost)
                rednet.send(tonumber(workIdHost),rednetCommon.getCommandPrefix().SLAVE_PREFIX .. os.getComputerLabel(),pProtocol)
                foundHost = true
                return workIdHost
            end
        end
    end
end

function updateStatus(msg)
	rednetCommon.send(idHost,rednetCommon.getCommandPrefix().STATUS .. msg)
end

function getCantReceiveOrReadyToReceive()
	return rednetCommon.getCantReceiveOrReadyToReceive()
end

