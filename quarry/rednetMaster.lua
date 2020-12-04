local debug = false
local slaves = {}
os.loadAPI("rednetCommon.lua")
local MasterCallback

local function printDebug(msg)
    if debug then
        print(msg)
    end
end

local function InsertSlaveIfNew(id,label)
    for key, value in pairs(slaves) do
        if value[2] == id then
            print("Slave already exists")
            return
        end
    end
    table.insert(slaves,{label,id})
    print("New slave added : " .. id .. " - " .. label)
end

local function toCallback(command,id,msg)
    printDebug("In callback master" .. id .. command .. msg)
    if command == rednetCommon.getCommandPrefix()["SLAVE_PREFIX"] then
        InsertSlaveIfNew(id,msg)
    elseif command == rednetCommon.getCommandPrefix()["STATUS"] then
        --TODO: IMPLEMENT FIND LABEL FROM ID
        print(textutils.formatTime(os.time(), true) .. " - " .. id .. " - " .. msg)
    elseif command == rednetCommon.getCommandPrefix()["ACTION"] then
        if MasterCallback~=nil then
            shell.run(MasterCallback,command,id,msg)
        end
    else
        print("Unhandled command " .. command .. " received from " .. id)
    end
end

function work(pProtocol,pHostname,pCallback)

    if rednetCommon.initiateModem() then
        printDebug("Modem initiated")
        rednet.host(pProtocol,pHostname)
        MasterCallback = pCallback
        return rednetCommon.initialize(pProtocol,toCallback)
    end
    return {}
end

function listSlaves()
    local slavesFormatted = "List of slaves : \n"
    for key, value in pairs(slaves) do
        slavesFormatted = slavesFormatted .. tostring(key) .. "--" .. value[2] .. " - "  .. value[1] .. "\n"
    end
    return slavesFormatted
end

function send(idOrLabel,message)
    local idToSendTo = 0
    local idNumber = tonumber(idOrLabel)
    if idNumber ~= nil then
        idToSendTo = idNumber
    else
        for key, value in pairs(slaves) do
            if value[1] == idOrLabel then
                idToSendTo = value[2]
                break
            end
        end
    end
    if idToSendTo == 0 then
        print "Not Valid Slave"
        return
    end
    rednetCommon.send(idToSendTo,rednetCommon.getCommandPrefix().ACTION .. message)
end

function add(id, label)
    InsertSlaveIfNew(id,label)
end

function sendAll(message)
    printDebug("Slaves : \n")
    for key, value in pairs(slaves) do
        rednetCommon.send(value[2],rednetCommon.getCommandPrefix().ACTION .. message)
    end
end