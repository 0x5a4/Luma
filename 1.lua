-- Get Command
return function (args, data, sender)
    local constructmsg = function (data)
        --It would be necessary to append the command id at the beginning but since its 0 it doesnt make a difference in the 
        --numerical value. So we might aswell not do it
        return string.char(args)..data
    end

    if args == 0 then
        --LED
        --If led is empty only 0 is send, since that is impossible normally. If we dont do this we get a PANIC
        socket:send(config.net.udp_response_port, sender.ip, #ledstate.led == 0 and string.char(0) or ledstate.led)
    elseif args == 1 then
        --POWER
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(tostring(ledstate.power)))
    elseif args == 2 then
        --Mode
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(tostring(ledstate.mode)))
    elseif args == 3 then
        --Speed
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(tostring(ledstate.speed)))
    elseif args == 40 then
        --LED Number
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(tostring(config.led.ledNum)))
    elseif args == 41 then
        --Led Byte Count
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(tostring(config.led.byteCount)))
    elseif args == 42 then
        --Global IP Address
        --Send the Global IP if global_ip isnt nil(It has been determined). Send "null" otherwise
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(tostring(global_ip and global_ip or "null")))
    elseif args == 43 then
        --Dummy
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(string.char(0xFF)))
    elseif args == 39 then
        --Ledstate
        local ledmsg = ""
        ledmsg = ledmsg + string.char(ledstate.power and 1 or 0) --Power
        ledmsg = ledmsg + string.char(ledstate.mode) --Mode
        ledmsg = ledmsg + string.char(bit.band(ledstate.speed,0x1100)) --Speed 1. byte
        ledmsg = ledmsg + string.char(bit.band(ledstate.speed, 0x0011)) --Speed 2. byte
        ledmsg = ledmsg + #ledstate.led > 0 and ledstate.led or string.char(0) --LED
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(ledmsg))
    end
end