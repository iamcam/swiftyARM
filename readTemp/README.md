#readTemp

ReadTemp is written for the Raspberry Pi2/3, but should be able to run on any similar Linux ARM device (armv7 & armv8). This version uses Swift 3.0 with package manager.

To run this code,

```
$ swift build
  Compile Swift Module 'SwiftyGPIO' (4 sources)
  Compile Swift Module 'readTemp' (3 sources)
  Linking .build/debug/readTemp
$ sudo .build/debug/readTemp
```

Requires a 1-wire DS18B20 temperature sensor and 2 LEDs for indicators. Ensure 1-wire GPIO is enabled on your ARM device. This sample code is intended to be HappyPath only; there's a good chance something will break if not configured properly. If you're running another small linux device, make sure to change the settings as necessary, including the GPIO pin numbers, as they may not all be available across all hardware platforms.


1. Connect the temperture sensor data wire to GPIO pin 4
2. LED to GPIO pin 6
3. Another LED to GPIO pin 21
4. Goes without saying, wire everything with the appropriate resistors in the right places

![readTemp circuit diagram](1wire-temp-sensor.png?raw=true "readTemp circuit diagram")
