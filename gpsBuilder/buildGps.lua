if not turtle then
	print("Error Not turtle")
	return
end

local mov = {}

mov.forward = function ()
	while not turtle.forward() do
		sleep(1)
	end
	return true
end
mov.back = function ()
	while not turtle.back() do
		sleep(1)
	end
	return true
end
mov.up = function ()
	while not turtle.up() do
		sleep(1)
	end
	return true
end
mov.down = function ()
	while not turtle.down() do
		sleep(1)
	end
	return true
end
mov.place = function ()
	while not turtle.place() do
		sleep(1)
	end
end

local base = nil
local tArgs = {...}
local xBase = tonumber(tArgs[1]) --Pos x ou la turtle se trouve
local zBase = tonumber(tArgs[2]) --Pos z ou la turtle se trouve

if turtle.getFuelLevel() < 600 then
	print("600 fuel is required")
	return
else
	if fs.exists("custom") then
		print("custom program detected")
		print("please Enter base Station number")
		local failFlag = false
		repeat
			if failFlag then
				print("Error Not number")
				print("try again")
			end
			write(" > ")
			base = tonumber(read())
			failFlag = true
		until type(base) == "number"
	end
	print("----------------PLACE TURTLE FACING POSITIVE X---------------------")
	print("Please Place 4 computers in slot one")
	print("4 modems in slot two")
	print("if mineing turtle then")
	print("1 disk drive in slot three")
	print("if not mineing then")
	print("4 disk drive in slot three")
	print("blank floopy disk in slot four")
	print("press Enter key to continue")
	while true do
		local event , key = os.pullEvent("key")
		if key == 28 then break end
	end
	print("Launching")
end

local set = {}
set[1] = {x = xBase+3,y = 255,z = zBase}
set[2] = {x = xBase,y = 252,z = zBase+3}
set[3] = {x = xBase-3,y = 255,z = zBase}
set[4] = {x = xBase,y = 252,z = zBase-3}

while turtle.up() do -- sends it up till it hits max hight
end

for a = 1,4 do
	for i = 1,2 do
		mov.forward()
	end
	turtle.select(1)
	mov.place()
	mov.back()
	turtle.select(2)
	mov.place()
	mov.down()
	mov.forward()
	turtle.select(3)
	mov.place()
	turtle.select(4)
	turtle.drop()
	-- make disk custom
	fs.delete("disk/startup")
	file = fs.open("disk/startup","w")
	file.write([[
fs.copy("disk/install","startup")
fs.delete("disk/startup")
if fs.exists("disk/custom") then
	fs.copy("disk/custom","custom")
	fs.delete("disk/custom")
end
print("sleep in 10")
sleep(10)
os.reboot()
]])
	file.close()
	if fs.exists("custom") then
		fs.copy("custom","disk/custom")
	end
		file = fs.open("disk/install","w")
		file.write([[
if fs.exists("custom") then
	shell.run("custom","host",]]..set[a]["x"]..","..set[a]["y"]..","..set[a]["z"]..","..(base or "nil")..[[)
else
	shell.run("gps","host",]]..set[a]["x"]..","..set[a]["y"]..","..set[a]["z"]..[[)
end
]])
		file.close()
	-- end make disk custom
	turtle.turnLeft()
	mov.forward()
	mov.up()
	turtle.turnRight()
	mov.forward()
	turtle.turnRight()
	peripheral.call("front","turnOn")
	mov.down()
	turtle.suck()
	turtle.select(3)
	turtle.dig()
	mov.up()
	-- reboot would be here
	turtle.turnRight()
	for i = 1,3 do
		mov.forward()
	end
	turtle.turnLeft()
	mov.forward()
	if a == 1 or a == 3 then
		for i = 1,3 do
		mov.down()
		end
	elseif a == 2 or a == 4 then
		for i = 1,3 do
		mov.up()
		end
	end
end

while turtle.down() do -- brings turtle down
end
turtle = tMove
print("Finished")