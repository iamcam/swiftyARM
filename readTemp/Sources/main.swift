/**
readTemp.swift
Copyright (c) 2016 Cameron Perry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
**/

import Foundation
import Glibc
import SwiftyGPIO

//.RaspberryPi2 also works with Raspberry Pi3
let gpios = SwiftyGPIO.GPIOs(for: .RaspberryPi2)

// indicator LED lit during temperature read
var led = gpios[.P6]!

// the LED that will blink on a separate thread
var tLED = gpios[.P21]!

//Clearer LED states
let ON = 1
let OFF = 0

var blink = false {
  didSet {
    tLED.value = OFF
  }
}

//You'll need to find the ID of your 1-wire temp sensor - DS18B20
let probeNames = ["28-03159199a5ff"]

//The probe will show up in here so long as you have 1-wire gpio enabled
let probeDirectory = "/sys/bus/w1/devices/"

//Prepares our GPIO pins & values
func loadIndicator() {
  led.direction = .OUT
  led.value = OFF
  tLED.direction = .OUT
  tLED.value = OFF
}


//reads from the probe, returns temperature in degrees C
func readProbe(name : String) -> Double {
  let path = "\(probeDirectory)\(name)/w1_slave"
  var outval = ""
  let BUFSIZE = 1024

  let fp = fopen(path, "r")

  // try reading from /sys/bus/w1/devices/{prob name}/w1_slave
  if fp != nil {
    var buf = [CChar](repeating:CChar(0), count:BUFSIZE)
    while fgets(&buf, Int32(BUFSIZE), fp) != nil {
      //outval += String.fromCString(buf)!
      outval += String(validatingUTF8:buf)!
    }
  }

  let temp : Double
  if let tempS = outval.split(byString:"t=").last, t = Double(tempS.trim()) {
    temp = Double(t)/1000.0
  } else {
    temp = 0.0
  }

  return Double(temp)
}

func doReading() -> Double{
  //Turn LED on to indicate we've begun reading the temperature
  led.value = ON
  let temp = readProbe(name: probeNames.first!)

  //sleep a little bit so we don't miss it. Not required
  usleep(1000)

  led.value = OFF
  return temp
}

var thread : NSThread?

func startThread() {
  if thread == nil {
    blink = true
    thread = NSThread() {
      while blink {
        tLED.value = ON
        usleep(50000)
        tLED.value = OFF
        usleep(50000)
      }
    }
  }

  if let thread = thread {
    thread.start()
  }
}


loadIndicator()

//Start blinking the light
startThread()
sleep(2)

//Demonstrate we can do something else at the same time
let probeValue = doReading()
print("\(probeValue) °C / \(probeValue * 1.8 + 32.0)°F")

// Keep blinking the light a little longer
sleep(2)
blink = false

exit(0)
