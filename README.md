## Whats this?
This project aims to create an easily expandable interface for controlling a ws2812 LED strip. Another goal was to make it not just accessible from a websocket
but from any device that can send UDP Messages.

## Motivation
I actually wrote an early version of this in the first Lockdown, but my lack of knowledge about Lua and electronics brought this project to a quick end.
I broke my LED strip and abandoned the project. 2 weeks ago while cleaning up my desk i stumbled across the NodeMCU and since I had already bought all the other necessary parts I thought: "Ok finish what you started. But this time inform yourself and do some research beforehand."

## Hardware-Setup
To use this project you'll need:
* A NodeMCU Dev Kit(generally just referred to as NodeMCU but NodeMCU is not the actual name its just the firmware)
* 1 ws2812-like led strip(WS2812, WS2812b, APA104, SK6812)
* A Power Supply capable of powering your strip(depends on length and led count)
* A Relay(For having everything turn on/off remotely)
* (Also some way to power the NodeMCU, e.g. a Micro-USB Cable)

1. Connect your strip's power wires to the PSU, one of them intercepted by the relay.
2. Connect the relays power to the NodeMCU(GND, VCC for 5V or 3V3 for 3.3V)
3. Connect the power-pin assigned in the [config](config.lua) to the relay's input(default: 5)
4. Connect the LED's data wire to Pin D4
5. Connect the Power Supply and the NodeMCU to mains voltage(or whatever) 

## Software-Setup

1. First you need to flash the [firmware](#firmware) onto your NodeMCU.
2. Now clone this repo and have a look at [config.lua](config.lua)(Insert your Wifi credentials and configure it to suit your needs)
3. Upload everything then restart the device([How?](#upload-program))

## Firmware
**Required Modules**: node, net, file, gpio, ws2812, color_utils, bit, tmr, wifi   
**Optional Modules**: http, mdns

**Where to build?**   
You can either use [NodeMCU Cloud build service](https://nodemcu-build.com/), my attached firmware, or [build yourself](https://nodemcu.readthedocs.io/en/release/build/#docker-image). 

**How to flash?**   
On Windows you can flash using [NodeMCU pyflasher](https://github.com/marcelstoer/nodemcu-pyflasher/releases).
On Linux you will have to use [esptool](https://github.com/espressif/esptool) which is terminal only

## Upload Program
Anything capable of uploading stuff to a ESP8266 could do this but I recommend [Andi Dittrich's](https://github.com/AndiDittrich) [NodeMCU-Tool](https://github.com/AndiDittrich/NodeMCU-Tool). Upload each .lua file and then restart your NodeMCU by typing ```nodemcu-tool terminal``` and then ```node.restart()```. You should see a lot of unreadable mess in your terminal and then some information about the firmware build. The LED on your board should start blinking, indicating that a Wifi Connection is being established. If the LED stops blinking the connection was made, if not you should check your Wifi Credentials once again.