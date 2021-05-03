-- Set Command
ledconvtmr = ledconvtmr and ledconvtmr or tmr.create()
setValue = function(index, value)
    if index >= 40 then
        print("Cannot modify value "..tostring(index).."(immutable)")
        return false
    end
    
    if (index == 0) then
        -- LED
        assert(#value % 3 == 0, "Cannot set LED Value. Data Length is not a multiple of 3")
        local i = 1
        local ledval = ""
        ledconvtmr:alarm(5, tmr.ALARM_AUTO, function ()
            if i < #value then
                local h, s, v = extract_hsv(value:sub(i, i+2))
                ledval = ledval..convertToLedString(h, s, v)
                i = i + 3
            else
                ledstate.led = ledval
                ledstate.ledhsv = value
                ledconvtmr:stop()
            end
        end)
    elseif index == 1 then
        -- Power
        local firstbyte = string.byte(value)
        if firstbyte == 0 then
            ledstate.power = false
        elseif firstbyte == 1 then
            ledstate.power = true
        elseif firstbyte == 0xFF then
            ledstate.power = not ledstate.power
        end
        print("Setting power to "..ledstate.power)
    elseif index == 2 then
        --Mode
        ledstate.mode = string.byte(value)
        print("Setting mode to "..ledstate.mode)
    elseif index == 3 then
        --Speed
        local speed = 0
        --Add each bit so numbers about 255 are possible
        for i = 1, #value do
            speed = bit.lshift(speed, 8)
            speed = bit.bor(speed, value:sub(i,i))
        end
        --Cap at timer maximum(1:54:30)
        ledstate.speed = speed <= 13741 and speed or 13741
        print("Setting speed to "..ledstate.speed)
    elseif index == 39 then
        --Ledstate
        setValue(1, value:sub(1,1))
        setValue(2, value:sub(2,2))
        setValue(3, value:sub(3, 4))
        setValue(0, value:sub(5, -1))
    end
end

return function(args, data)
    setValue(args, data)
    ledstate() --Save and Apply
    return true --Indicate that we wish to notify config.net.notifyIP of the changes that were made
end