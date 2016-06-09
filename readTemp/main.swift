import Foundation
import Glibc

let gpios = SwiftyGPIO.GPIOs(for: .RaspberryPi2)
var led = gpios[.P6]!
var tLED = gpios[.P21]!
var blink = false

let probeNames = ["28-03159199a5ff"]
let probeDirectory = "/sys/bus/w1/devices/"

func loadIndicator() {
     led.direction = .OUT
     led.value = 0
     tLED.direction = .OUT
     tLED.value = 0
}


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
     led.value = 1
     let temp = readProbe(name: probeNames.first!) * 1.8 + 32.0
     usleep(1000)
     led.value = 0
     return temp
}

var thread : NSThread?

func startThread() {
     if thread == nil {
          blink = true
          thread = NSThread() {
	  	 while blink {
		     tLED.value = 1
		     usleep(250000)
		     tLED.value = 0
		     usleep(250000)
		 }
		 exit(0)
		 
	  }
     }

     if let thread = thread {
     	thread.start()
	thread.stop()
     }
}

startThread()
sleep(3)
loadIndicator()
let probeValue = doReading()

print("\(probeValue)°F")

sleep(3)
blink = false

