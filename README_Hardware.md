# Smart Gym Hardware

The Smart Gym hardware consists of sensor nodes that connect to the phone via Bluetooth. Each sensor node contains electronics centered around an Arduino Nano 33 BLE and a PCB, enclosed in a 3D-printed enclosure. 

Circuit schematic for Smart Gym Node, including the Arduino Nano 33 BLE, the power control circuit (left), and the haptic motor circuit (right):

## ![Image](./hardware/hw_NANO33BLE/circuit.png)

Assembled sensor node, with Arduino Nano 33 BLE connected to haptic motor and power control circuits via PCB:

## ![pcb_assembled](./hardware/pcb_assembled.png)

## Power Control Circuit

The power control circuit is designed to allow the user to power on the device with a single button press. The device will then remain powered on until the arduino sends an "off" signal (High/3.3V) from pin D12. This will cut off current from the connected Voltage Source (In this case, a 9V battery), and power off the arduino. 

The first transistor (top) connects the +9V source to the VIN pin and has its gate connected to a button connected to the 9V source. When this button is held, 9V is connected to the gate, turning on the first transistor and allowing voltage to pass into VIN. As a result of the pass-transistor characteristics of the NMOS, VIN has a resulting voltage of 7.5V (9V-Vthreshold) (Vthreshold=2.5V). Then, as the Arduino is powered on, the 5V pin will output +5V, which will keep the transistor’s gate voltage above the threshold, even when the button is released. While the voltage on the gate is above 5V, the diode prevents current from flowing backward into the 5V pin. If the gate’s voltage drops below 5V, current can flow through the diode, so the gate is always maintained at at least 5V. 

While the device is powered on, D12 will be set to LOW, keeping the lower transistor closed. However, when the device will power off, D12 will be set to HIGH, turning on the second transistor. This pulls the first transistor’s gate to 0V, turning off the first transistor, and disconnecting VIN from the battery. The resistor between the 5V pin and the first transistor’s gate is included to allow a voltage drop between the pin and the gate, which allows the gate to be pulled to 0V without drawing too much excess current from the 5V pin.

This method powers on/off the device as soon as the button is pressed / the HIGh signal is sent to the second transistor.

## Haptic Motor

The haptic motor circuit uses a BJT transistor, which is modulated by current, rather than voltage. For this, we simply connect the transistor’s C and E pins between the 9V battery and the motor and ground. The gate is connected to the Arduino’s D11 pin through a resistor used to reduce the haptic feedback intensity. Setting D11 to HIGH for a brief amount of time will cause the node to vibrate.


## PCB

To connect the electronics, we used a printed circuit board (PCB) designed in EAGLE, based on our circuit diagram. The board schematic describes the wire connections between our electronic components and the locations of our components on the board. This is a 2-sided PCB, measuring 34.3mm by 49.5mm, and 1.6mm thick. 

PCB Schematic:
## ![pcb](./hardware/pcb.jpg)

In the enclosure, the battery will be placed adjacent to the PCB, with the charging port on the same side as the Arduino’s USB port. The battery’s dimensions are 48.5 mm × 26.5 mm × 17.5 mm, so the electronics will fit within a 52mm × 50mm × 30mm enclosure. The haptic motor can be taped along the inside of the enclosure after soldering the electronics. 





Arduino code:
In addition to library manager libraries: https://github.com/FemmeVerbeek/Arduino_LSM9DS1
library manager libraries: Adafruit_AHRS, ArduinoBLE

NOTE: In order to use the 5V pin, you must solder the VUSB pad
