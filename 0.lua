-- Set Command
return function(args, data)
    if (args == 0) then
        -- LED
        ledstate.led = data
    elseif args == 1 then
        -- Power
        local firstbyte = string.byte(data)
        if firstbyte == 0 then
            ledstate.power = false
        elseif firstbyte == 1 then
            ledstate.power = true
        elseif firstbyte == 0xFF then
            ledstate.power = not ledstate.power
        end
    elseif args == 2 then
        --Mode
        ledstate.mode = string.byte(data)
    elseif args == 3 then
        --Speed
        local speed = 0
        for i = 1, #data do
            speed = speed + string.byte(data, i)
        end
        --Cap at timer maximum(1:54:30)
        ledstate.speed = speed <= 6870947 and speed or 6870947
    end
    ledstate() --Save and Apply
end