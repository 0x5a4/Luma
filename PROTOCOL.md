# The Protocol

## Structure
```
< head > < args > . . .
00000000 00000000 . . .
```

The first byte is the header of the message, describing holding relevant information about what to do with it. The first 2 header-bits indicate which command is being sent, the last 6 carry additional arguments depending on the command(In current implementations this is only the value ID). This header byte is then followed by any number of bytes representing the data given to the command(e.g. LED colors)

## Commands
Each command is mapped to a certain number(represented by the first two bytes of the header byte). This number can also be reffered to as the command's ID.
Depending on this ID a different lua file is executed(e.g. "[<span>0</span>.lc](0.lua)" for SET) internally. 

### Command Table

Commandname | ID | Byte Representation
------------|----| -------------------
SET | 0 | 00
GET | 1 | 01
NOTIFY | 2 | 10

### Set Command
Set a Value to the attached data. The command arguments determine the [Value ID](#values).
If configured, a NOTIFY command is send to the notifyIP indicating the changes made

##### Example
```
Message: 00000001 00000001
         < head > Value(1 for true)
```
What does it MEAN???
* First 2 bits: ```00``` -> Command ID 0 -> Set Command
* Remaining 6 Bytes(args): ```000001``` -> Value ID 1 -> Power
* First byte of the data is ```00000001``` -> true
* Set the Power value to true 

### Get Command
Get a Value's data. The command arguments determine the [Value ID](#values)
Answers on the response port set in the config using a [notify](#notify-command) command

##### Examples
```
01000001
< head >
```
What does it MEAN???
* First 2 bits: ```01``` -> Command ID 1 -> Get Command
* Remaining 6 bits(args): ```000001``` -> Value ID 1 -> Power
* Power value is: ```00000000``` (false)
* Send ```00000000``` to message sender on the response port(e.g. 192.168.0.0:65001)

```
Message: 01000000
         < head >
```
What does it MEAN???
* First 2 bits: ```01``` -> Command ID 1 -> Get Command
* Remaining 6 bits(args): ```000000``` -> Value ID 0 -> Led
* Led value is ```00000000 00000000 11111111``` (first led blue)
* Send ```00000000 00000000 11111111``` to message sender on the response port(e.g. 192.168.0.0:65001)

### Notify Command
Used to notify others about values. Also carries a device ID in case you have multiple devices across multiple networks who happen to have the same IP-Address

##### Example
```
10000001 11111111 00000000
< head > deviceid data
```
What does it MEAN???
* First 2 bits: ```10``` -> Command ID 2 -> Notify Command
* Remaining 6 bits(args): ```000001``` -> Value ID 1 -> Power
* deviceid is ```11111111``` -> 255 
* data is ```00000000``` -> false
* Power for device with ID 255 has changed to false 


## Values

Valuename | ID | Byte Representation
----------|----| -------------------
[led](#led) | 0 | ```000000```
[power](#power) | 1 | ```000001``` 
[mode](#mode) | 2 | ```000010```
[speed](#speed) | 3 | ```000011```
[state](#state) | 4 | ```000100```
[lednum](#lednum) | 5 | ```000101```
[globalIP](#globalIP) | 6 | ```000110```
[dummy](#dummy) | 7 | ```000111```

### led
Led Configuration. Transfered as HSV in 3 bytes. Converted locally according to the byteCount.
This is done to decrease the message length and provide a more universal interface.
It consists of segments made from 3 bytes representing the color of one LED. 
The first 9 bits of the segment represent the colors hue(0-360), the next 7 the saturation(0-100), the next 7 the value(0-100)
And yes theres one bit remaining, but we dont need it so it is ignored.

### power
Whether the strip should be turned on. ```0``` is off, ```1``` is on. Sending ```11111111```(255) inverts the current one

### mode
Mode | ID | description
-----|----|------------
static | 0 | No animation
rainbow | 1 | cycle through the rainbow wheel. [led](#led) configuration is ignored
positive_cycle | 2 | shift the whole led configuration in positive direction. 1 Pixel at a time, speed determined by [speed](#speed)
negative_cycle | 3 | shift the whole led configuration in the negative direction. 1 Pixel at a time, speed determined by [speed](#speed)

### speed
Speed to play the current animation in miliseconds. 1 "Speed" corresponds to 500ms. Data is seen as one giant byte so if you send 2 bytes their seen as
a 16-bit number. Max is 13741 so 2 bytes should be enough

### lednum
The length of the LED strip. Set within the device config. This value is immutable

### Global IP
Returns the Global IP of the device. Only works if http is included in the firmware("null" otherwise). This value is immutable

## dummy
Just a mock value to test if the device is reachable. Obviously immutable

## state
The entire configuration at once using the following format:

```
00000000 00000000 00000000 00000000 00000000 00000000 . . .
<lednum> <power > <mode  > <speed          > <led         >
```
lednum is simply ignored when receiving


