print("Man I am so lost right now!")
 local x, y, z = gps.locate(5)
 if not x then
 print("fail")
 else
 print("I am at (" .. x .. ", " .. y .. ", " .. z .. ")")
 end
