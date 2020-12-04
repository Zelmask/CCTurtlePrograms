local CommonProtocol = ""
local CommonCallback = ""
local messages = {}

local useModem = false
local debug = false

local cantReceiveOrReadyToReceive = false

local CommandPrefixs = {
    ["SLAVE_PREFIX"] = "Registering as slave : ",
    ["STATUS"] = "Status : ",
    ["ACTION"] = "Action : "
}

function getCommandPrefixCount()
    return 3
end

function getCommandPrefix()
    return CommandPrefixs
end

local function printDebug(msg)
    if debug then
        print(msg)
    end
end

local function messagesHandler()
    if useModem then
        printDebug("modemOn")
        while true do
            if #messages > 0 then
                local message = messages[1]
                local id = message[1]
                local msg = message[2]
                local found = false
                printDebug(tostring(getCommandPrefixCount()))
                for key, value in pairs(getCommandPrefix()) do
                    local prefix = value
                    printDebug(prefix)
                    if string.find(msg,prefix) then
                        printDebug("Prefix found, calling calback")
                        found = true
                        local msgWithoutCommand = string.sub(msg,#prefix+1)
                        CommonCallback(prefix,id,msgWithoutCommand)
                        break
                    end
                end
                if not found then
                    print("Unhandled Message from " .. id)
                end
                table.remove(messages,1)
            else
                os.sleep(0.25)
            end
        end
    end
end

local function rednetLoop()
    if useModem then
        cantReceiveOrReadyToReceive = true
        printDebug("Initialization done set to true")
        print("Listening...")
		while true do
            local id, msg = rednet.receive(CommonProtocol)
            printDebug("Received something")
            if msg ~= nil  then
                printDebug("msg is " .. msg)
                table.insert(messages,{id,msg})
			else
				print(id .. " sending something but message is null")
            end
            printDebug("rednetLoop")
		end
	end
end

function initiateModem()
    if not useModem then
        for k, v in pairs( rs.getSides() ) do
            useModem = peripheral.isPresent( v ) and peripheral.getType( v ) == "modem"
            if useModem then
                rednet.open(v)
                return useModem
            end
        end
    end
    return useModem
end

function initialize(pProtocol, pCallback)
    cantReceiveOrReadyToReceive = false
    if initiateModem() then
        printDebug("Initiate modem worked")
        CommonProtocol = pProtocol
        CommonCallback = pCallback
        printDebug(CommonProtocol)
        printDebug(CommonCallback)
        return {rednetLoop,messagesHandler}
    end
end

function send(id,msg)
    if useModem and id~=nil then
        printDebug("Sending with " .. tostring(id) .. msg .. CommonProtocol)
        rednet.send(id,msg, CommonProtocol)
    end
end

function getCantReceiveOrReadyToReceive()
    return cantReceiveOrReadyToReceive
end