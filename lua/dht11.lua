pin = 3 --GPIO0
function getTemp()
status,temp,humi,temp_decimial,humi_decimial = dht.read(pin)
if( status == dht.OK ) then
  -- Float firmware using this example
  print(string.format("DHT Temperature:%d.%02d;Humidity:%d.%02d\r\n",temp,temp_decimial,humi,humi_decimial))
elseif( status == dht.ERROR_CHECKSUM ) then
  print( "DHT Checksum error." );
elseif( status == dht.ERROR_TIMEOUT ) then
  print( "DHT Time out." );
end
end

--- Get temperature and humidity data and send data to thingspeak.com
function sendData()
getTemp()
-- conection to thingspeak.com
print("Sending data to thingspeak.com")
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)
-- api.thingspeak.com 184.106.153.149
conn:connect(80,'184.106.153.149') 
conn:send("GET /update?key=WRITE_API_KEY&field2="..temp.."&field1="..humi.." HTTP/1.1\r\n") 
conn:send("Host: api.thingspeak.com\r\n") 
conn:send("Accept: */*\r\n") 
conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
conn:send("\r\n")
conn:on("sent",function(conn)
                      print("Closing connection")
                      conn:close()
                  end)
conn:on("disconnection", function(conn)
                      print("Got disconnection...")
  end)
end
-- send data every 20 minutes to thing speak
tmr.alarm(2, 1200000 * 30, 1, function() sendData() end )
