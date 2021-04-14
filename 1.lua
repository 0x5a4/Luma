-- Get Command
return function (args, data, sender)
    if args == 0 then
        --LED
        --If led is empty only 0 is send, since that is impossible normally. If we dont do this we get a PANIC
        socket:send(sender.port, sender.ip, #ledstate.led == 0 and string.char(0) or ledstate.led)
    elseif args == 1 then
        --POWER
        socket:send(sender.port, sender.ip, tostring(ledstate.power))
    elseif args == 2 then
        --Mode
        socket:send(sender.port, sender.ip, tostring(ledstate.mode))
    elseif args == 3 then
        --Speed
        socket:send(sender.port, sender.ip, tostring(ledstate.speed))
    elseif args == 128 then
        --LED Number
        socket:send(sender.port, sender.ip, tostring(config.led.ledNum))
    elseif args == 129 then
        --Led Byte Count
        socket:send(sender.port, sender.ip, tostring(config.led.byteCount))
    elseif args == 130 then
        --Global IP Address
        --Send the Global IP if global_ip isnt nil(It has been determined). Send "null" otherwise
        socket:send(sender.port, sender.ip, tostring(global_ip and global_ip or "null"))
    end
end