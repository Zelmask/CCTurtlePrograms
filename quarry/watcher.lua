os.loadAPI("rednetMaster.lua")

function split(pString, pPattern)
	local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = pString:find(fpat, 1)
	while s do
		   if s ~= 1 or cap ~= "" then
		  table.insert(Table,cap)
		   end
		   last_end = e+1
		   s, e, cap = pString:find(fpat, last_end)
	end
	if last_end <= #pString then
		   cap = pString:sub(last_end)
		   table.insert(Table, cap)
	end
	return Table
 end

function main_loop()
 while true do
	local s = read()
	local statusMessage = nil
	if s == "clear" then
		statusMessage = nil
		term.clear()
	end

	if statusMessage then
		print(statusMessage)
	end

	local splitCommand = split(s," ")
	if #splitCommand == 2 then
		if splitCommand[1] == "return" then
			if splitCommand[2] == "all" then
				rednetMaster.sendAll("return")
			else
				rednetMaster.send(splitCommand[2],splitCommand[1])
			end
		elseif splitCommand[1] == "resume" then
			if splitCommand[2] == "all" then
				rednetMaster.sendAll("resume")
			else
				rednetMaster.send(splitCommand[2],splitCommand[1])
			end
		elseif splitCommand[1] == "again" then
			if splitCommand[2] == "all" then
				rednetMaster.sendAll("again")
			else
				rednetMaster.send(splitCommand[2],splitCommand[1])
			end
		elseif splitCommand[1] == "list" then
			if splitCommand[2] == "slaves" then
				print(rednetMaster.listSlaves())
			end
		end
	elseif #splitCommand == 3 then
		if splitCommand[1] == "add" then
			rednetMaster.add(tonumber(splitCommand[2]),splitCommand[3])
		end
	else
		print("Invalid command")
	end
	os.sleep(0.05)
 end
end


local parallels = rednetMaster.work("QuarryMining","Master",nil)
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