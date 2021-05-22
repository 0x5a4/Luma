local config = {}
config.wifi = {}
config.led = {}
config.net = {}

--Files excluded from compilation to lua bytecode. Leave unchanged if you have no idea what that means
config.compileExceptions = {"init.lua", "config.lua", "ledstate.lua"}
config.systemIndicationLedPin = 0 --LED showing that the device is turned on, connecting to wifi (NodeMCU LED = 0). Can be any Pin basically
config.sysLedIdleMode = false --Set to true to have the Led turned on when idle
config.deviceid = 0 --Change this if you plan on using multiple devices. Should also be unique across multiple netorks

--Wifi Config. Used to allow for control via UDP
config.wifi.pwd = "Password123"
config.wifi.ssid = "SSID" --SSID is just the Network Name e.g. "MyCoolWifi"

--LED Config. Since this project is only usable with WS2812 alike led stripes, ledNum and byteCount are required. powerPin is optional
config.led.ledNum = 150 --Number of LED's controlled with this Controller
config.led.byteCount = 3 --RGB/RGBW
config.led.powerPin = 5 -- This Pin is set to High/Low to determine if the LED strip should be turned on/off

--Net Config
config.net.udp_port = 65000 --The Port used for listening to UDP Messages
config.net.udp_response_port = 65001 --The Port used for Responding
config.net.ip_address = nil --Override the IP given to the device e.g "192.168.4.5"(Quatation Marks required). Set to nil to use the DHCP(automatic) one
--Ip to notify of any changes made. The given command will just be repeated and needs to be reinterpreted by the other side.
--When sending to a multicast group make sure the device isnt a part of that since that will create an infinite loop. Broadcast is not advised
config.net.notifyIP = nil
config.net.device_name = "" --Set device hostname. Also sets the mdns hostname if mdns is included
config.net.print_global_ip = false --Makes a GET Request to 'http://api.ipify.org' to retrieve the Global IP and then prints it. Only works if HTTP is included
return config