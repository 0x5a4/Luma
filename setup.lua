--configure GPIO
gpio.mode(config.led.powerPin, gpio.OUTPUT)

--Init ws2812 module
ws2812.init()

--[[
    Array holding the different animations, aka specifying what to do in what mode
    1 -> static
    2 -> rainbow
    3 -> lcycle
    4 -> rcycle
--]]
animations = dofile("loadanimations.lc")

--This table holds the LED Configuration. It is also responsible for applying and saving any changes made
ledstate = {}
--Load previous led configuration
if file.exists("ledstate.lua") then
    ledstate = dofile("ledstate.lua")
else
    --Does not exist create default
    ledstate.power = false
    ledstate.led = ''
    ledstate.mode = 0
    ledstate.speed = 1000
end

local meta = {}
meta.__call = function (table, dontSave)
    --Print what the ledstate is
    print("LED State:")
    print("\tled: "..ledstate.led)
    print("\tpower: "..tostring(ledstate.power))
    print("\tmode: "..tostring(ledstate.mode))
    print("\tspeed: "..tostring(ledstate.speed).."ms")

    --Apply
    if (table.power) then
        gpio.write(config.led.powerPin, gpio.HIGH)
        animations[ledstate.mode + 1]() --plus 1 cause arrays start at 1 but indexes start at 0 to keep it consistent
    else
        gpio.write(config.led.powerPin, gpio.LOW)
        animationtimer:stop() --LED is not powered anyway so we might as well stop the animationtimer
    end

    --Save
    if (not dontSave) then
        local state_file = file.open("ledstate.lua", "w+")
        state_file:writeline("--GENERATED DO NOT MODIFY")
        state_file:writeline("local s={}")
        state_file:writeline("s.power="..tostring(table.power))
        state_file:writeline("s.led='"..tostring(table.led).."'")
        state_file:writeline("s.mode="..tostring(table.mode).."")
        state_file:writeline("s.speed="..tostring(table.speed))
        state_file:writeline("return s")
        state_file:close()
    end
end
setmetatable(ledstate, meta) --Set the Metatable so ledstate becomes callable and we can do ledstate() to save and apply.

--Apply LED State, dont save
ledstate(true)

--Setup UDP Socket
socket = net.createUDPSocket()
socket:listen(config.net.udp_port);
socket:on("receive", function(s, data, port, ip)
    print("Message received from "..ip.." on port "..port)
    local sender = {ip=ip, port=port}
    local metabyte = string.byte(data)
    local commandindex = bit.rshift(metabyte, 6);
    if file.exists(commandindex..".lc") then
        local args = bit.band(metabyte, 0x3F) --0x3F is 00111111 which, when used with a bitwise AND gives us only the last 6 bits(the ones we care about)
        dofile(commandindex..".lc")(args, data:sub(2, -1), sender)
    else
        print("Unrecognized command index "..commandindex)
    end
end)

--Register Wifi Event Monitors
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function (T)
    print("Successfully connected to "..T.SSID.." on channel "..T.channel);
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function (T)
    print("Got IP via DHCP:".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..T.netmask.."\n\tGateway IP: "..T.gateway)
    IPCONFIG = {}
    IPCONFIG.netmask = T.netmask
    IPCONFIG.gateway = T.gateway
    if (config.net.ip_address ~= nil) then
        print("Overriding Ip with "..tostring(config.net.ip_address).." specified in config");
        IPCONFIG = {}
        IPCONFIG.ip = config.net.ip_address
        wifi.sta.setip(IPCONFIG)
    else
        IPCONFIG.ip = T.IP
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
    ledtimer = nil
    ledflag = nil
    collectgarbage("collect")
end)

--Configure Wifi
wifi.setmode(wifi.STATION)
wifi.sta.config(config.wifi)

--Startup Feedback
print("Setup completed in "..((tmr.now() - setuptime) / 1000).."ms")
setuptime = nil