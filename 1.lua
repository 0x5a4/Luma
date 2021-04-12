-- Get Command
--TODO: Make Config 'gettable' but not 'settable'
return function (args, data, sender)
    if args == 0 then
        --LED
        socket:send(sender.port, sender.ip, #ledstate.led = 0 and string.char(0,0,0) or ledstate.led)
    elseif args == 1 then
        --POWER
        socket:send(sender.port, sender.ip, tostring(ledstate.power))
    elseif args == 2 then
        --Mode
        socket:send(sender.port, sender.ip, tostring(ledstate.mode))
    elseif args == 3 then
        --Speed
        socket:send(sender.port, sender.ip, tostring(ledstate.speed))
    end
end