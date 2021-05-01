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
        buffer = ws2812.newBuffer(361, config.led.byteCount)
        for i = 0, 360 do
            if config.led.byteCount == 3 then
                buffer:set(i + 1, hsv2rgb(i, 100, 100))
            else
                buffer:set(i + 1, hsv2rgbw(i, 100, 100))
            end
        end
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
