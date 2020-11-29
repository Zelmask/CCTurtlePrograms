tickDuration = 0.05
broacastSleepRatio = 2
receiveSleepRatio = 1

function broadcast(s)
	rednet.broadcast(s)
	os.sleep(tickDuration*broacastSleepRatio)
end