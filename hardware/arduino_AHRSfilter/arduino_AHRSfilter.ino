#include <Arduino_LSM9DS1.h>
#include <Adafruit_AHRS.h>
#include <ArduinoBLE.h>
#define sensorRate 104.00
Adafruit_Mahony filter;

BLEService AHRSfilter("A123"); // create service
BLEFloatCharacteristic RollCharacteristic("2A19", BLERead | BLENotify); //create Characteristic
BLEFloatCharacteristic PitchCharacteristic("2A20", BLERead | BLENotify); //create Characteristic
BLEFloatCharacteristic HeadingCharacteristic("2A21", BLERead | BLENotify); //create Characteristic

//PINS
#define powerdrain 12
#define haptic 11

unsigned long start_time;

void setup() {
  pinMode(powerdrain, OUTPUT);
  pinMode(haptic, OUTPUT);
  digitalWrite(powerdrain, LOW);
  digitalWrite(haptic, LOW);

  // attempt to start the IMU:
  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU");
    // stop here if you can't access the IMU:
    while (true);
  }
  // Calibration:
  // Gyroscope code
   IMU.setGyroFS(2);
   IMU.setGyroODR(5);
   IMU.setGyroOffset (1.370026, -0.591858, 0.469818);
   IMU.setGyroSlope (1.205162, 1.202537, 1.155080);
  // Magnetometer code
   IMU.setMagnetFS(0);
   IMU.setMagnetODR(8);
   IMU.setMagnetOffset(5.055542, 24.595947, 13.364258);
   IMU.setMagnetSlope (1.345936, 1.178488, 1.197922);
  // Accelerometer code
   IMU.setAccelFS(3);
   IMU.setAccelODR(5);
   
  // start the filter to run at the sample rate:
  filter.begin(sensorRate);
  Serial.print("Orientation:\n");

  // BLE Setup  
  BLE.begin();
  BLE.setLocalName("Node1");
  BLE.setAdvertisedService(AHRSfilter);
  AHRSfilter.addCharacteristic(RollCharacteristic);
  AHRSfilter.addCharacteristic(PitchCharacteristic);
  AHRSfilter.addCharacteristic(HeadingCharacteristic);
  BLE.addService(AHRSfilter);
  BLE.advertise();

  // Serial
  Serial.begin(9600);
  //temporary counter
  start_time = millis();
}

void loop() {
  //power control---------------
  unsigned long nowtime=millis();
  
  if ( nowtime - start_time >= 10000)
    digitalWrite(powerdrain, HIGH);
 
  if(nowtime%1000 < 400)
    digitalWrite(haptic,HIGH);
  else
    digitalWrite(haptic,LOW);
  //----------------------------
  
  BLEDevice central = BLE.central();
  
  //Output Values
  float roll, pitch, heading;
  //IMU values
  float xAcc, yAcc, zAcc,
        xGyro,yGyro,zGyro,
        xMag, yMag, zMag;
  if(IMU.accelerationAvailable() && 
     IMU.gyroscopeAvailable() &&
     IMU.magneticFieldAvailable()
     ){
    IMU.readAcceleration(xAcc, yAcc, zAcc);
    IMU.readGyroscope(xGyro, yGyro, zGyro);
    IMU.readMagneticField(xMag, yMag, zMag);
  }
  //update filter
  filter.update(xGyro,yGyro,-zGyro,xAcc,yAcc,-zAcc,-xMag,yMag,-zMag);
  //get filter output:
  roll = filter.getRoll();
  pitch = filter.getPitch();
  heading = filter.getYaw();
  //print values
  Serial.print("heading: ");
  Serial.print(heading);
  Serial.print("\tpitch: ");
  Serial.print(pitch);
  Serial.print("\troll: ");
  Serial.println(roll);

  RollCharacteristic.writeValue(roll);
  PitchCharacteristic.writeValue(pitch);
  HeadingCharacteristic.writeValue(heading);

}
