----------------------------
-------------------------
---------------------
--------------- TODO : Faire un API modem pour Master + Slaves qui utilisent HostName pour Master et Lookup pour slaves et les slaves écrivent avec send et l'id
---------------- https://computercraft.info/wiki/Rednet_(API)



os.loadAPI("fuelUp.lua")
os.loadAPI("rednetSlave.lua")
os.loadAPI("quarry.lua")

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

local function sendToMaster(s)
	print(s)
	rednetSlave.updateStatus(s)
end

function main_loop()
	sendToMaster("Doing Quarry again...")
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
		local moveDownCount = 0
		for i=1, 3 do
			while not turtle.down() do
				if not turtle.digDown() then
					break
				end
			end
			moveDownCount = moveDownCount+1
		end
		for i=1, moveDownCount do
			while not turtle.up() do
				turtle.digUp()
			end
		end
	end
	quarry.main_loop()
	sendToMaster("End of Quarry...awaiting instructions")
end

function toCallback(command,id,msg)	
	if command == rednetCommon.getCommandPrefix().ACTION then
		if msg == "again" then
			againAtPosition = false
			main_loop()
		elseif msg == "resume" then
			againAtPosition = true
			main_loop()
		elseif msg == "return" then
			print("Calling Return")
			quarry.comeBack()
			sendToMaster("Going back!")
		end
	end
end

local parallels = rednetSlave.work("QuarryMining","Master",toCallback)
table.insert(parallels,function() 
	while not rednetCommon.getCantReceiveOrReadyToReceive() do
		os.sleep(0.5)
	end
	main_loop()
end)
if #parallels == 1 then
	main_loop()
else
	parallel.waitForAll(parallels[1],parallels[2],parallels[3])
end