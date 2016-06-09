import Foundation
import Glibc

let gpios = SwiftyGPIO.GPIOs(for: .RaspberryPi2)
var led = gpios[.P6]!
var tLED = gpios[.P21]!

//Clearer LED states
let ON = 1
let OFF = 0

var blink = false {
    didSet {
        tLED.value = OFF
    }
}

let probeNames = ["28-03159199a5ff"]
let probeDirectory = "/sys/bus/w1/devices/"

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
		 exit(0)
		 
	  }
     }

     if let thread = thread {
     	thread.start()
     }
}

startThread()
sleep(2)
loadIndicator()
let probeValue = doReading()

print("\(probeValue) °C / \(probeValue * 1.8 + 32.0)°F")

sleep(2)
blink = false

