//taken from https://gist.github.com/shfitz/a8704a890497cd43789a3bc029179245 

// based off of Tom Igoe's version here : https://itp.nyu.edu/physcomp/lessons/accelerometers-gyros-and-imus-the-basics

#include <Arduino_LSM9DS1.h>
#include "MadgwickAHRS.h"
#include <ArduinoBLE.h>

BLEService MadgwickFilter("A123"); // create service
BLEFloatCharacteristic RollCharacteristic("2A19", BLERead | BLENotify); //create Characteristic
BLEFloatCharacteristic PitchCharacteristic("2A20", BLERead | BLENotify); //create Characteristic
BLEFloatCharacteristic HeadingCharacteristic("2A21", BLERead | BLENotify); //create Characteristic

// initialize a Madgwick filter:
Madgwick filter;
// sensor's sample rate is fixed at 104 Hz:
const float sensorRate = 104.00;

void setup() {
  Serial.begin(9600);
  
  // BLE Setup  
  BLE.begin();
  BLE.setLocalName("Node1");
  BLE.setAdvertisedService(MadgwickFilter);
  MadgwickFilter.addCharacteristic(RollCharacteristic);
  MadgwickFilter.addCharacteristic(PitchCharacteristic);
  MadgwickFilter.addCharacteristic(HeadingCharacteristic);
  BLE.addService(MadgwickFilter);
  BLE.advertise();
    
  // attempt to start the IMU:
  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU");
    // stop here if you can't access the IMU:
    while (true);
  }
  // start the filter to run at the sample rate:
  filter.begin(sensorRate);
}

void loop() {
  BLEDevice central = BLE.central();
  // values for acceleration and rotation:
  float xAcc, yAcc, zAcc;
  float xGyro, yGyro, zGyro;

  // values for orientation:
  float roll, pitch, heading;
  // check if the IMU is ready to read:
  if (IMU.accelerationAvailable() &&
      IMU.gyroscopeAvailable()) {
    // read accelerometer &and gyrometer:
    IMU.readAcceleration(xAcc, yAcc, zAcc);
    IMU.readGyroscope(xGyro, yGyro, zGyro);

    // update the filter, which computes orientation:
    filter.updateIMU(xGyro, yGyro, zGyro, xAcc, yAcc, zAcc);

    // print the heading, pitch and roll
    roll = filter.getRoll();
    pitch = filter.getPitch();
    heading = filter.getYaw();
    Serial.print("Orientation: ");
    Serial.print(heading);
    Serial.print(" ");
    Serial.print(pitch);
    Serial.print(" ");
    Serial.println(roll);
        //Send heading, pitch, and roll via BLE
    RollCharacteristic.writeValue(roll);
    PitchCharacteristic.writeValue(pitch);
    HeadingCharacteristic.writeValue(heading);
    delay(1000);
  // for testing: sends values for 250ms and stops
    // if (central) {
    //   while (central.connected()) {
    //     RollCharacteristic.writeValue(roll);
    //     PitchCharacteristic.writeValue(pitch);
    //     HeadingCharacteristic.writeValue(heading);
    //     delay(250);
    //   }
    // }    
  }
}
