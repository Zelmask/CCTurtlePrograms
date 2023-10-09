----------------------------
-------------------------
---------------------
--------------- TODO : Faire un API modem pour Master + Slaves qui utilisent HostName pour Master et Lookup pour slaves et les slaves écrivent avec send et l'id
---------------- https://computercraft.info/wiki/Rednet_(API)



os.loadAPI("./fuelUp.lua")
os.loadAPI("./rednetPlus.lua")
local stop = false
local USEMODEM = peripheral.isPresent("right") and peripheral.getType("right") == "modem"
print(USEMODEM)

local againAtPosition = false

local tArgs = {...}
for i=1,#tArgs do
	local arg = tArgs[i]
	if string.find(arg, "-") == 1 then
		for c=2,string.len(arg) do
			local ch = string.sub(arg,c,c)
			if ch == 'd' then
				againAtPosition = true
			else
				write("Invalid flag '")
				write(ch)
				print("'")
			end
		end
	end
end

local function broadcast(s)
	modemOpen()
	s2 = os.getComputerLabel() .. " : " .. s
	print(s2)
	rednetPlus.broadcast(s2,"miningTurtle")
end

function modemOpen()
	if USEMODEM and not rednet.isOpen("right") then
		rednet.open("right")
	end
end

function modemClose()
	if USEMODEM and rednet.isOpen("right") then
		rednet.close("right")
	end
end

function main_loop()
	broadcast("Doing Quarry again...")
	if not againAtPosition then
		fuelUp.refuel()
		turtle.turnLeft()
		turtle.dig()
		turtle.turnRight()
		for i=1, 16 do
			turtle.select(i)
			
			data = turtle.getItemDetail()
			
			if data ~= nil and data.name == "enderstorage:ender_storage" then
				break
			end
		end
		for i=1, 32 do
			while not turtle.forward() do
				turtle.dig()
			end
		end
		turtle.turnLeft()
		turtle.place()
		turtle.turnRight()
		for i=1, 3 do
			while not turtle.down() do
				turtle.digDown()
			end
		end
		for i=1, 3 do
			while not turtle.up() do
				turtle.digUp()
			end
		end
	end
	shell.run("quarry")
	broadcast("End of Quarry...awaiting instructions : again or stop")
end

function modemListen()	
	if USEMODEM then
		while not stop do
			modemOpen()
			local id, msg, distance = rednet.receive()
			if msg ~= nil then
				print("Received following message " .. msg)
				if string.find(msg, "again " .. os.getComputerLabel()) ~= nil then
					againAtPosition = false
					main_loop()
				elseif string.find(msg, "resume " .. os.getComputerLabel()) ~= nil then
					againAtPosition = true
					main_loop()
				elseif string.find(msg, "stop " .. os.getComputerLabel()) ~= nil then
					stop = true
					broadcast(os.getComputerLabel() .. " over and out!")
				end
			end
			os.sleep(rednetPlus.tickDuration*rednetPlus.receiveSleepRatio)
		end
		modemClose()
	end
end

parallel.waitForAll(modemListen, main_loop)