To run this code,

```
swiftc *.swift && sudo ./main
```

Requires a 1-wire DS18B20 temperature sensor and 2 LEDs for indicators. Ensure 1-wire GPIO is enabled on your ARM device. This sample code is intended to be HappyPath only; there's a good chance something will break if not configured properly.


1. Connect the temperture sensor data wire to GPIO pin 4
2. LED to GPIO pin 6
3. Another LED to GPIO pin 21
4. Goes without saying, wire everything with the appropriate resistors in the right places
