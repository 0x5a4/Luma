--configure GPIO
gpio.mode(config.led.powerPin, gpio.OUTPUT)

--Init ws2812 module
ws2812.init()

--HSV Conversion Methods

--Extract Hue, Saturation and Value from a 3 byte chain
extract_hsv = function (source)
    assert(#source == 3, "HSV Extraction Target length needs to be exactly 3")
    local firstbyte = string.byte(source:sub(1))
    local secondbyte = string.byte(source:sub(2))
    local thirdbyte = string.byte(source:sub(3))
    local hue = bit.bor(bit.lshift(firstbyte, 1), bit.band(secondbyte, 0x80)) --First 9 bytes
    local saturation = bit.band(secondbyte, 0x7F) --next 7
    local value = bit.rshift(bit.band(thirdbyte, 0xFE), 1) --next 7
    return hue, saturation, value
end

--Convert HSV to RGB or RGBW depending on config.led.byteCount and return as String
convertToLedString = function (hue, saturation, value)
    if config.led.byteCount == 3 then
        local r, g, b = hsv2rgb(hue, saturation, value)
        return string.char(r,g,b)
    else
        local r, g, b, w = hsv2rgbw(hue, saturation, value)
        return string.char(r,g,b,w)
    end
end

hsv2rgb = function (hue, saturation, value)
    assert(hue <= 360 and hue >= 0, "Hue must be in range 0-360(was "..hue..")")
    assert(saturation <= 100 and value >= 0, "Saturation must be in range 0-100(was "..saturation..")")
    assert(value <= 100 and value >= 0, "Value must be in range 0-100(was "..value..")")

    local s = saturation / 100
    local v = value / 100
    local chroma = v * s
    local h = hue / 60
    local x = chroma * (1 - math.abs(h % 2 - 1))
    local r,g,b = 0,0,0
    if h <= 1 then
        r,g,b = chroma, x, 0
    elseif h <= 2 then
        r,g,b = x, chroma, 0
    elseif h <= 3 then
        r,g,b = 0, chroma, x
    elseif h <= 4 then
        r,g,b = 0, x, chroma
    elseif h <= 5 then
        r,g,b = x, 0, chroma
    elseif h <= 6 then
        r,g,b = chroma, 0, x
    else
        r,g,b = 0,0,0
    end
    local m = v - chroma
    r = (r + m) * 255
    g = (g + m) * 255
    b = (b + m) * 255
    return math.floor(r), math.floor(g), math.floor(b)
end

hsv2rgbw = function (hue, saturation, value)
    local r, g, b = hsv2rgb(hue, saturation, value)
    local w = math.min(r, math.min(g, b))
    r = r - w
    g = g - w
    b = b - w
    return r, g, b, w
end

--[[
    Array holding the different animations, aka specifying what to do in what mode
    1 -> static
    2 -> rainbow
    3 -> positive_cycle
    4 -> negative_rcycle
--]]
animations = dofile("loadanimations.lc")

--This table holds the LED Configuration. It is also responsible for applying and saving any changes made
ledstate = {}
--Load previous led configuration
if file.exists("ledstate.lua") then
    ledstate = dofile("ledstate.lua")
else
    --Does not exist, create default
    ledstate.power = false
    ledstate.led = ''
    ledstate.ledhsv = ''
    ledstate.mode = 0
    ledstate.speed = 2
end
--Translate the Speed value to milliseconds
ledstate.speedMS = function()
    return ledstate.speed * 500
end

local meta = {}
meta.__call = function (table, dontSave)
    --Print what the ledstate is
    print("LED State:")
    print("\tled: "..ledstate.led)
    print("\tledhsv: "..ledstate.ledhsv)
    print("\tpower: "..tostring(ledstate.power))
    print("\tmode: "..tostring(ledstate.mode))
    print("\tspeed: "..tostring(ledstate.speed).."("..ledstate.speedMS().."ms)")

    --Apply
    if (table.power) then
        gpio.write(config.led.powerPin, gpio.HIGH)
        animations[ledstate.mode + 1]() --plus 1 cause arrays start at 1 but our indexes start at 0 to keep it consistent
    else
        gpio.write(config.led.powerPin, gpio.LOW)
        animationtimer:stop() --LED is not powered anyway so we might as well stop the animationtimer
    end

    --Invert dontSave so if the argument isnt given we still apply(nil is false)
    if (not dontSave) then
        local state_file = file.open("ledstate.lua", "w+")
        state_file:writeline("--GENERATED DO NOT MODIFY")
        state_file:writeline("local s={}")
        state_file:writeline("s.power="..tostring(table.power))
        state_file:writeline("s.led='"..table.led.."'")
        state_file:writeline("s.ledhsv='"..table.ledhsv.."'")
        state_file:writeline("s.mode="..tostring(table.mode).."")
        state_file:writeline("s.speed="..tostring(table.speed))
        state_file:writeline("return s")
        state_file:close()
    end
end
setmetatable(ledstate, meta) --Set the Metatable, so ledstate becomes callable and we can do ledstate() to save and apply.

--Apply LED State, dont save
ledstate(true)

--Setup UDP Socket
socket = net.createUDPSocket()
socket:listen(config.net.udp_port);
socket:on("receive", function(s, data, port, ip)
    print("Message received from "..ip.." on port "..port)
    local sender = {ip=ip, port=port}
    local metabyte = string.byte(data) --First byte
    local commandindex = bit.rshift(metabyte, 6); --First 2 bits of metabyte
    if file.exists(commandindex..".lc") then
        local args = bit.band(metabyte, 0x3F) --0x3F is 00111111 which, when used with a bitwise AND gives us only the last 6 bits(the ones we care about)
        local status, returnval = pcall(dofile(commandindex..".lc"), args, data:sub(2, -1))
        if status then
            if returnval then
                if config.net.notifyIP then
                    --Command returned true, notifyIP specified, indicating that we should repeat the command to notifyIP so they can react to the changes
                    socket:send(config.net.udp_response_port, config.net.notifyIP, data)
                end
            end
        else
            print("Error executing command #"..commandindex..":")
            print(returnval)
        end
    else
        print("Unrecognized command index "..commandindex)
    end
end)

--Register Wifi Event Monitors
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function (T)
    print("Successfully connected to "..T.SSID.." on channel "..T.channel.."(RSSI: "..wifi.sta.getrssi()..")");
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function (T)
    print("Got IP via DHCP:".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..T.netmask.."\n\tGateway IP: "..T.gateway)
    IPCONFIG = {}
    IPCONFIG.netmask = T.netmask
    IPCONFIG.gateway = T.gateway
    --Override IP if requested
    if (config.net.ip_address ~= nil) then
        print("Overriding Ip with "..tostring(config.net.ip_address).." specified in config");
        IPCONFIG = {}
        IPCONFIG.ip = config.net.ip_address
        wifi.sta.setip(IPCONFIG)
    else
        IPCONFIG.ip = T.IP
    end

    --Setup MDNS Server
    if mdns and config.net.device_name then --Check if included and enabled
        local result, errmsg = pcall(function() mdns.register(config.net.device_name, {
            port=config.net.udp_port,
            service="luma"
        })end)
        if (not result) then
            print("Failed to register mDNS")
            print(errmsg)
        else 
            print("MDNS Setup completed. Now available as: "..config.net.device_name..".local providing _luma._tcp")
        end
    end
    
    --Determine Global IP
    if http and config.net.print_global_ip then
        http.get("http://api.ipify.org/", nil, function(code, data)
            if code == 200 then
               global_ip = data
               print("Global IP is "..data)
            else
                print("Could not determine Global IP. Status code: "..code)
            end
        end)
    end

    --Setup completed, stop led blink
    if (ledtimer:state()) then
        ledtimer:unregister()
        if config.sysLedIdleMode then
            gpio.write(config.systemIndicationLedPin, gpio.LOW)
        else
            gpio.write(config.systemIndicationLedPin, gpio.HIGH)
        end
    end
    ledtimer, ledflag = nil, nil
    
    collectgarbage("collect")
end)

--Configure Wifi
if config.net.device_name then
    local status, err = pcall(wifi.sta.sethostname("NODE-"..config.net.device_name))
    if status then
        print("Cannot set Hostname:")
        print(err)
    end
end
wifi.setmode(wifi.STATION)
print("Attempting Connection to "..config.wifi.ssid)
wifi.sta.config(config.wifi)