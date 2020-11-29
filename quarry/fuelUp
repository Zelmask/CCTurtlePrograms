function refuel()

	local refuelSucces = true
	local selectedIndex = 1
	while turtle.getFuelLevel()<turtle.getFuelLimit() and refuelSucces do
		
		for i=selectedIndex, 16 do
			turtle.select(i)
			local data = turtle.getItemDetail()
			refuelSucces = data and turtle.refuel()
			if refuelSucces then
				selectedIndex = i
				break
			end
		end
	end
end