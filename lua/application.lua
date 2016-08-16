local module = {}  
m = nil

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

    print("ds18b20_start....\n ")
    
    -- Pin donde esta conectado el sensor
    --gpio0 = 3 --D3
    gpio3 = nil -- por defecto D9
    gpio4 = 2 --D4
    
    
    ds18b20.setup(gpio3)
    addrs = ds18b20.addrs()
    if (addrs ~= nil) then
        print("Total DS18B20 sensors: "..table.getn(addrs))
    end

    -- Just read temperature
    print("Temperature: "..ds18b20.read().."'C\n")

    -- Get temperature of first detected sensor in Fahrenheit
    --print("Temperature: "..t.read(nil,t.F).."'F")

    print("Temperature: "..ds18b20.read(nil,ds18b20.K).."'K")
    
    -- Query the second detected sensor, get temperature in Kelvin
    --if (table.getn(addrs) >= 2) then
    --    print("Second sensor: "..t.read(addrs[2],t.K).."'K")
    --end

    -- Don't forget to release it after use
    ds18b20 = nil
    ds18b20 = nil
    package.loaded["ds18b20"]=nil
    
end

function module.start()  
  ds18b20_start()
  --mqtt_start()
end

return module  
