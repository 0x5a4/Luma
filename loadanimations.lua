--General Timer for animations, required by all animations(except "static")
animationtimer = animationtimer and animationtimer or tmr:create()

--Create a new Buffer and fill it with the led configuration
createBuffer = function ()
    buffer = ws2812.newBuffer(config.led.ledNum, config.led.byteCount)
    buffer:replace(ledstate.led:sub(1, config.led.ledNum * config.led.byteCount))
end

return {
    function () --static
        print("I am static")
        ws2812.write(ledstate.led:sub(1, config.led.ledNum * config.led.byteCount))
    end,
    function () --rainbow
        print("I hunt terrorist")
        --Now we fill the Buffer with the entire color wheel
        buffer = ws2812.newBuffer(360, config.led.byteCount) --We dont care about the Configuration anyway. Also size it to 360 since we want all rainbow colors
        local g, r, b, w = 0, 0, 0, 0
        for i = 0, 359 do
            if config.led.ledNum == 4 then
                --Transform the color wheel to grb to hsv to grbw. Puh thats unnecessary complicated
                g, r, b, w = color_utils.hsv2grbw(color_utils.grb2hsv(color_utils.colorWheel(i)))
                buffer:set(i, string.char(r, g, b, w))
            else
                g, r, b = color_utils.colorWheel(i)
                buffer:set(i + 1, string.char(r, g, b))
            end
        end
        g, r, b, w = nil, nil, nil, nil
        collectgarbage("collect")
        animationtimer:alarm(ledstate.speedMS, tmr.ALARM_AUTO, function ()
            buffer:shift(1, ws2812.SHIFT_CIRCULAR)
            ws2812.write(buffer:sub(1, config.led.ledNum - 1))
        end)
    end,
    function () --positive_cycle
        print("I spin positive")
        createBuffer()
        animationtimer:alarm(ledstate.speedMS, tmr.ALARM_AUTO, function ()
            buffer:shift(1, ws2812.SHIFT_CIRCULAR)
            ws2812.write(buffer)
        end)
    end,
    function () --negative_cycle
        print("I spin negative")
        createBuffer()
        animationtimer:alarm(ledstate.speedMS, tmr.ALARM_AUTO, function ()
            buffer:shift(-1, ws2812.SHIFT_CIRCULAR)
            ws2812.write(buffer)
        end)
    end
}
