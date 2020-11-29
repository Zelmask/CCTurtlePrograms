os.loadAPI("inv.lua")
os.loadAPI("t.lua")
os.loadAPI("rednetPlus.lua")

local x = 0
local y = 0
local z = 0
local max = 16
local deep = 64
local facingfw = true

local OK = 0
local ERROR = 1
local LAYERCOMPLETE = 2
local OUTOFFUEL = 3
local FULLINV = 4
local BLOCKEDMOV = 5
local USRINTERRUPT = 6

local CHARCOALONLY = false
local USEMODEM = false
local PRINT_DEBUG = false

local goBack = false


-- Arguments
local tArgs = {...}
for i=1,#tArgs do
	local arg = tArgs[i]
	if string.find(arg, "-") == 1 then
		for c=2,string.len(arg) do
			local ch = string.sub(arg,c,c)
			if ch == 'c' then
				CHARCOALONLY = true
			elseif ch == 'd' then
				PRINT_DEBUG = true
			else
				write("Invalid flag '")
				write(ch)
				print("'")
			end
		end
	end
end

USEMODEM = peripheral.isPresent("right") and peripheral.getType("right") == "modem"


function out(s)

	s2 = s
	
	if PRINT_DEBUG then
		s2 = s .. " @ [" .. x .. ", " .. y .. ", " .. z .. "]"
	end
	
	print(textutils.formatTime(os.time(), true) .. " - " .. s2)
	
	if USEMODEM then
		rednetPlus.broadcast(os.getComputerLabel() .. " : " .. s2, "miningTurtle")
	end  
end

function dropInChest()
	turtle.turnLeft()
	
	local success, data = turtle.inspect()
	
	if success then
		if data.name == "minecraft:chest" or data.name == "ironchest:iron_chest" or data.name == "enderstorage:ender_storage" then
		
			out("Dropping items in chest")
			
			for i=1, 16 do
				turtle.select(i)
				
				data = turtle.getItemDetail()
				
				if data ~= nil and
						(data.name == "minecraft:coal" and CHARCOALONLY == false) == false and
						(data.damage == nil or data.name .. data.damage ~= "minecraft:coal1") then

					turtle.drop()
				end
			end
		end
	end
	
	turtle.turnRight()
	
end

function goDown()
	while true do
		if turtle.getFuelLevel() <= fuelNeededToGoBack() then
			if not refuel() then
				return OUTOFFUEL
			end
		end
	
		if not turtle.down() then
			turtle.up()
			addZ()
			return
		end
		removeZ()
	end
end

function fuelNeededToGoBack()
	return -z + x + y + 2
end

function refuel()
	for i=1, 16 do
		-- Only run on Charcoal
		turtle.select(i)
		
		item = turtle.getItemDetail()
		if item and
				item.name == "minecraft:coal" and
				(CHARCOALONLY == false or item.damage == 1) and
				turtle.refuel(1) then
			return true
		end
	end
	
	return false
end

function moveH()
	if inv.isInventoryFull() then
		print("Dropping trash")
		inv.dropTrash()
		
		if inv.isInventoryFull() then
			print("Stacking items")
			inv.stackItems()
		end
		
		if inv.isInventoryFull() then
			out("Full inventory!")
			return FULLINV  
		end
	end
	
	if turtle.getFuelLevel() <= fuelNeededToGoBack() then
		if not refuel() then
			out("Out of fuel!")
			return OUTOFFUEL
		end
	end
	
	if facingfw and y<max-1 then
	-- Going one way
		local dugFw = t.dig()
		if dugFw == false then
			out("Hit bedrock, can't keep going")
			return BLOCKEDMOV
		end
		t.digUp()
		t.digDown()
	
		if t.fw() == false then
			return BLOCKEDMOV
		end
		
		y = y+1
	
	elseif not facingfw and y>0 then
	-- Going the other way
		t.dig()
		t.digUp()
		t.digDown()
		
		if t.fw() == false then
			return BLOCKEDMOV
		end
		
		y = y-1
		
	else
		if x+1 >= max then
			t.digUp()
			t.digDown()
			return LAYERCOMPLETE -- Done with this Y level
		end
		
		-- If not done, turn around
		if facingfw then
			turtle.turnRight()
		else
			turtle.turnLeft()
		end
		
		t.dig()
		t.digUp()
		t.digDown()
		
		if t.fw() == false then
			return BLOCKEDMOV
		end
		
		x = x+1
		
		if facingfw then
			turtle.turnRight()
		else
			turtle.turnLeft()
		end
		
		facingfw = not facingfw
	end
	
	return OK
end

function modemListen()	
	if USEMODEM then
		out(os.getComputerLabel() .. " is Listening...")
		while not goBack do
			local id, msg, distance = rednet.receive()
			if msg ~= nil then
				print("Received following message " .. msg)
				if string.find(msg, "return " .. os.getComputerLabel()) ~= nil then
					goBack = true
				end
			end
			os.sleep(rednetPlus.tickDuration*rednetPlus.receiveSleepRatio)
		end
	end
end

function digLayer()
	
	local errorcode = OK

	while errorcode == OK do
		if goBack then
			out("Going back to start :)!")
			return USRINTERRUPT
		end
		errorcode = moveH()
	end
	
	if errorcode == LAYERCOMPLETE then
		return OK
	end
	
	return errorcode  
end

function goToOrigin()
	
	if facingfw then
		
		turtle.turnLeft()
		
		t.fw(x)
		
		turtle.turnLeft()
		
		t.fw(y)
		
		turtle.turnRight()
		turtle.turnRight()
		
	else
		
		turtle.turnRight()
		
		t.fw(x)
		
		turtle.turnLeft()
		
		t.fw(y)
		
		turtle.turnRight()
		turtle.turnRight()
		
	end
	
	x = 0
	y = 0
	facingfw = true
	
end

function goUp()

	while z < 0 do
		
		t.up()
		
		addZ()
		
	end
	
	goToOrigin()
	
end

function removeZ()
	z= z-1
end

function addZ()
	z = z+1
end

function mainloop()

	while true do
		local errorcode = digLayer()
	
		if errorcode ~= OK then
			goUp()
			return errorcode
		end
		
		goToOrigin()
		
		for i=1, 3 do
			t.digDown()
			success = t.down()
		
			if not success then
				goUp()
				return BLOCKEDMOV
			end

			removeZ()
		end
		os.sleep(0.05)
	end
end

function main_program()
	out("Starting Quarry")

	while true do

		goDown()

		local errorcode = mainloop()
		if errorcode ~= FULLINV then
			inv.dropTrash()
		end
		dropInChest()
		
		if errorcode ~= FULLINV then
			break
		end
		
		os.sleep(0.05)
	end
	out("Done")
end

parallel.waitForAll(modemListen, main_program)