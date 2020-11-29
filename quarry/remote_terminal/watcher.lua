os.loadAPI("rednetPlus.lua")
local USEMODEM = false

for k, v in pairs( rs.getSides() ) do
	USEMODEM = peripheral.isPresent( v ) and peripheral.getType( v )
	if USEMODEM then
		break
	end
end

function listen()
 if USEMODEM then
	print("Listening...")
	 while true do
		id, msg, distance = rednet.receive()
		if msg ~= nil then
			print(textutils.formatTime(os.time(), true) .. " - " .. msg)
		end
	 end
 end
end


function main_loop()
 while true do
	local s = read()
	if s == "clear" then
		term.clear()
	elseif s == "returnAll" then
		print("Sending...")
		rednetPlus.broadcast("return Mining1")
		rednetPlus.broadcast("return Mining2")
		rednetPlus.broadcast("return Mining3")
		rednetPlus.broadcast("return Mining4")
	elseif s == "stopAll" then
		print("Sending...")
		rednetPlus.broadcast("stop Mining1")
		rednetPlus.broadcast("stop Mining2")
		rednetPlus.broadcast("stop Mining3")
		rednetPlus.broadcast("stop Mining4")
	elseif s == "resumeAll" then
		print("Sending...")
		rednetPlus.broadcast("resume Mining1")
		rednetPlus.broadcast("resume Mining2")
		rednetPlus.broadcast("resume Mining3")
		rednetPlus.broadcast("resume Mining4")
	elseif s == "againAll" then
		print("Sending...")
		rednetPlus.broadcast("again Mining1")
		rednetPlus.broadcast("again Mining2")
		rednetPlus.broadcast("again Mining3")
		rednetPlus.broadcast("again Mining4")
	elseif s == "backup" then
		rednetPlus.broadcast(s)
	else
		print("Sending...")
		rednetPlus.broadcast(s)
	end
	sleep(0.05)
 end
end

--end of file run everything
parallel.waitForAll(listen, main_loop)