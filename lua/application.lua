local module = {}  
m = nil
WRITEKEY="ZXKQ6RBIYQA6DZWG" -- Tu API Key de thingspeak.com
working_count = 0

--- INTERVAL ---
-- In milliseconds. Remember that the sensor reading, 
-- reboot and wifi reconnect takes a few seconds
time_between_sensor_readings = 60000                               

-- Sends a simple ping to the broker
local function send_ping()  
    m:publish(config.ENDPOINT .. "ping","id=" .. config.ID,0,0)
end

-- Sends my id to the broker for registration
local function register_myself()  
    m:subscribe(config.ENDPOINT .. config.ID,0,function(conn)
        print("Successfully subscribed to data endpoint")
    end)
end

local function mqtt_start()  
    m = mqtt.Client(config.ID, 120)
  
    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
        print(topic .. ": " .. data)
        -- do something, we have received a message
      --  execute_command(data)
      end
    end)
  
    -- Connect to broker
    m:connect(config.HOST, config.PORT, 0, 1, function(con) 
        register_myself()
        -- And then pings each 1000 milliseconds
        tmr.stop(6)
        tmr.alarm(6, 1000, 1, send_ping)
    end) 

end

local function ds18b20_start()

    working_count = working_count + 1

    print("sendData_start....\n ")
    
    -- Pin donde esta conectado el sensor
    --gpio0 = 3 --D3
    gpio3 = nil -- por defecto D9
    gpio2 = 4 --D4
    
    ds18b20.setup(gpio2)
    addrs = ds18b20.addrs()

    if (addrs ~= nil) then
        if ( table.getn(addrs) ~= 0 ) then
            -- Lo utilizamos para que de tiempo a enviar el dato por el protocolo tcp 
            if( working_count == 2 ) then
                print("working_count: "..working_count.."")
                print("Going to deep sleep "..(time_between_sensor_readings/1000).." seconds")
                node.dsleep(time_between_sensor_readings*1000)             
            else
            print("Total DS18B20 sensors: "..table.getn(addrs))
            -- Leemos la temperatura dos veces por si hay algun error
            t = ds18b20.read()
            t = ds18b20.read()
            print("Temperature: "..t.."'C\n")
            sendData(t)
            end
        end 
    end
    
    
    -- Query the second detected sensor, get temperature in Kelvin
    --if (table.getn(addrs) >= 2) then
    --    print("Second sensor: "..t.read(addrs[2],t.K).."'K")
    --end

    -- Don't forget to release it after use
    --ds18b20 = nil
    --ds18b20 = nil
    --package.loaded["ds18b20"]=nil
end

-- Enviar datos a https://api.thingspeak.com
function sendData(temp)
    conn = nil
    conn = net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, payload)success = true print(payload)end)
    conn:on("connection",
    function(conn, payload)
    print("Connectado")
    conn:send('GET /update?key='..WRITEKEY..'&field1='..temp..'HTTP/1.1\r\n\Host: api.thingspeak.com\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n')end)
    conn:on("disconnection", function(conn, payload) print('Desconectado') end)
    conn:connect(80,'184.106.153.149')
end

function module.start()  

  ds18b20_start()
  -- send data every 10000 ms to thing speak
  tmr.alarm(1,10000, 1, function() ds18b20_start() end)
  --mqtt_start()
end

return module  
