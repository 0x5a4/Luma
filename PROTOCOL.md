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
[state](#state) | 39
[lednum](#lednum) | 40
[globalIP](#globalIP) | 42
[dummy](#dummy) | 43

### led
Led Configuration. Transfered as HSV in 3 bytes. Converted locally acording to the byteCount.
This is done to decrease the message length for and provide a more universal interface.
It consists of segments made from 3 bytes representing the color of one LED. 
The first 9 bits of the segment represent the colors hue(0-360), the next 7 the saturation(0-100), the next 7 the value(0-100)
And yes theres one bit remaining, but we dont need it so it is ignored.

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
a 16-bit byte. Max is 13741 so 2 bytes should be enough

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


