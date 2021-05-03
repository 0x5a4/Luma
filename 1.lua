-- Get Command
return function (args, data, sender)
    local constructmsg = function (d)
        --It would be necessary to append the command id at the beginning but since its 0 it doesnt make a difference in the 
        --numerical value. So we might aswell not do it
        return string.char(args)..d
    end

    if args == 0 then
        --LED
        --If led is empty only 0 is send, since that is impossible normally. If we dont do this we get a PANIC
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(#ledstate.ledhsv == 0 and string.char(0) or ledstate.ledhsv))
    elseif args == 1 then
        --POWER
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(string.char(ledstate.power and 1 or 0)))
    elseif args == 2 then
        --Mode
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(string.char(ledstate.mode)))
    elseif args == 3 then
        --Speed
        --Split speed into 2 bytes(It might be bigger than 255)
        local speedmsg = string.char(bit.band(ledstate.speed, 0xFF00), bit.band(ledstate.speed, 0x00FF))
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(speedmsg))
    elseif args == 40 then
        --LED Number
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(string.char(config.led.ledNum)))
    elseif args == 42 then
        --Global IP Address
        --Send the Global IP if global_ip isnt nil(It has been determined). Send "null" otherwise
        socket:send(config.net.udp_response_port, sender.ip, constructmsg(global_ip and global_ip or "null"))
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
    print("Successfully send reply to "..sender.ip)
end