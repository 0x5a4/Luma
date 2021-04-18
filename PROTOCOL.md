# The Protocol

## Structure
```
< meta > < args > . . .
00000000 00000000 . . .
```

The Protocol starts with a meta or header byte. The first 2 bits indicate which command is being sent, the last 6 carry additional arguments
depending on the command. This meta byte is then followed by any number of bytes representing the data given to the command(e.g. LED colors)

## Commands
Each command is mapped to a certain number(represented by the first two bytes of the meta byte). This number can also be reffered to as the command's id.
Depending on this id a different lua file is executed(e.g. "<span>0</span>.lc" for SET) internally. 

### Command Table

Commandname | ID 
------------|----
SET | 0 
GET | 1

### Set Command
Set a Value to the attached data. The command arguments determine the [Value ID](#values).

##### Examples
```
Message: 00000001 00000001
         <meta>   Value(1 for true)
```
What does the Program see?
* First 2 bits: ```00``` -> Command ID 0 -> Set Command
* Remaining 6 Bytes(args): ```000001``` -> Value ID 1 -> Power
* First byte of the data is ```00000001``` -> true
* Set the Power value to true 

```
Message: 00000000 00000000 00000000 11111111
            <meta>   Red    Green     Blue
```

What does the Program see?
* First 2 bits: ```00``` -> Command ID 0 -> Set Command
* Remaining 6 bits(args): ```000000``` -> Value ID 0 -> Led
* Set Led to ```00000000 00000000 11111111```
* 0 Green 0 Red 0 Blue -> First Led blue

### Get Command
Get a Value's data. The command arguments determine the [Value ID](#values)
Answers on the same port as the message was received

##### Examples
```
01000001
<meta>
```
What does the Program see?
* First 2 bits: ```01``` -> Command ID 1 -> Get Command
* Remaining 6 bits(args): ```000001``` -> Value ID 1 -> Power
* Power value is: ```00000000``` (false)
* Send ```00000000``` to message sender (e.g. 192.168.0.0:65000)

```
Message: 01000000
         <meta>
```
What does the Program see?
* First 2 bits: ```01``` -> Command ID 1 -> Get Command
* Remaining 6 bits(args): ```000000``` -> Value ID 0 -> Led
* Led value is ```00000000 00000000 11111111``` (first led blue)
* Send ```00000000 00000000 11111111``` to message sender (e.g. 192.168.0.0:65000)


## Values

Valuename | ID 
----------|----
[led](#led) | 0 
[power](#power) | 1 
[mode](#mode) | 2
[speed](#speed) | 3
[lednum](#lednum) | 128
[bytesPerLED](#bytesPerLED) | 129
[globalIP](#globalIP) | 130
[dummy](#dummy) | 131
[ledstate](#ledstate) | 132

### led
LED Configuration. RGB or RGBW(depends on your strip) Pattern of any length

### power
Whether the strip should be turned on. 0 is off, 1 is on. Sending 11111111 inverts the current one
### mode

Mode | ID | description
-----|----|------------
static | 0 | No animation
rainbow | 1 | cycle through the rainbow wheel. [led](#led) configuration is ignored
positive_cycle | 2 | shift the whole led configuration in positive direction. 1 Pixel at a time, speed determined by [speed](#speed)
negative_cycle | 3 | shift the whole led configuration in the negative direction. 1 Pixel at a time, speed determined by [speed](#speed)

### speed
Speed to play the current animation in miliseconds. 1 "Speed" corresponds to 500ms. Data is seen as one giant byte so if you give 2 bytes their seen as
a 16-bit byte

### lednum
The length of the LED strip. Set within the device config. This value is immutable

### bytesPerLED
How many Bytes Per Color of the LED(3 for RGB/4 for RGBW). This value is immutable

### Global IP
Returns the Global IP of the device. Only works if http is included in the firmware("null" otherwise). This value is immutable

## dummy
Just a mock value to test if the device is reachable. Obviously immutable


