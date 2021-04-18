-- Set Command
-- TODO: Broadcast changes

setValue = function(index, value) 
    if index >= 40 then
        print("Cannot modify value "..tostring(index).."(immutable)")
        return false
    end
    
    if (index == 0) then
        -- LED
        ledstate.led = value
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
    elseif index == 2 then
        --Mode
        ledstate.mode = string.byte(value)
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