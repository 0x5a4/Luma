setuptime = tmr.now()
--Load Config
config = dofile("config.lua")

--System Indication LED
ledtimer = tmr.create()
ledflag = false
if config.systemIndicationLedPin ~= nil then
    gpio.mode(config.systemIndicationLedPin, gpio.OUTPUT)
    ledtimer:alarm(500, tmr.ALARM_AUTO, function ()
        if (ledflag) then
            gpio.write(config.systemIndicationLedPin, gpio.HIGH)
        else
            gpio.write(config.systemIndicationLedPin, gpio.LOW)
        end
        ledflag = not ledflag
    end)
end

--Start Compilation if necessary
for k, v in pairs(file.list()) do
    if (k:sub(-4, -1) == ".lua") then
        local flag = true
        --Check if were allowed to compile it
        for i = 1, #config.compileExceptions do
            if (config.compileExceptions[i] == k) then
                --Looks like we are not, so fck it
                flag = false
                break
            end
        end
        --Compile if flag is still set
        if (flag) then
            uart.write(0, "Compiling "..k.."...")
            node.compile(k)
            file.remove(k)
            print("Done!")
        end
    end
end

--Preparation finished. Now do what we actually want to do
dofile("setup.lc")

--Startup Feedback
print("Setup completed in "..((tmr.now() - setuptime) / 1000).."ms")
setuptime = nil