#include <Arduino_LSM9DS1.h>
#include <Adafruit_AHRS.h>
#include <ArduinoBLE.h>
#define sensorRate 104.00
Adafruit_Mahony filter;

BLEService AHRSfilter("A123"); // create service
BLEFloatCharacteristic RollCharacteristic("2A19", BLERead | BLENotify); //create Characteristic
BLEFloatCharacteristic PitchCharacteristic("2A20", BLERead | BLENotify); //create Characteristic
BLEFloatCharacteristic HeadingCharacteristic("2A21", BLERead | BLENotify); //create Characteristic

BLEService HapticFeedback("A124");
BLEByteCharacteristic switchCharacteristic("2A57", BLERead | BLEWrite);

//PINS
#define powerdrain 12
#define haptic 11

unsigned long start_time;
<<<<<<< Updated upstream
char* deviceName = "SmartGymBros_kidney";
=======
bool hapticState = true;
>>>>>>> Stashed changes

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
   IMU.setGyroOffset (0.202271, -0.971649, 0.442047);
   IMU.setGyroSlope (1.202876, 1.170078, 1.419463);
  // Magnetometer code
   IMU.setMagnetFS(0);
   IMU.setMagnetODR(8);
   IMU.setMagnetOffset(-10.064087, 18.947754, 18.128662);
   IMU.setMagnetSlope (1.145179, 1.314404, 1.053118);
  // Accelerometer code
   IMU.setAccelFS(3);
   IMU.setAccelODR(5);
   IMU.setAccelOffset(0.003756, -0.012898, 0.019816);
   IMU.setAccelSlope (0.989642, 0.994564, 0.977860);
   
  // start the filter to run at the sample rate:
  filter.begin(sensorRate);
  Serial.print("Orientation:\n");

  // BLE Setup  
  BLE.begin();
  BLE.setLocalName(deviceName);
  BLE.setAdvertisedService(AHRSfilter);
  AHRSfilter.addCharacteristic(RollCharacteristic);
  AHRSfilter.addCharacteristic(PitchCharacteristic);
  AHRSfilter.addCharacteristic(HeadingCharacteristic);
  BLE.addService(AHRSfilter);
  BLE.advertise();

  HapticFeedback.addCharacteristic(switchCharacteristic);
  BLE.addService(HapticFeedback);

  // Serial
  Serial.begin(9600);
  //temporary counter
  start_time = millis();

  pinMode(LEDR, OUTPUT);
  digitalWrite(LEDR, HIGH);
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
  Serial.print(deviceName);
  Serial.print("\theading: ");
  Serial.print(heading);
  Serial.print("\tpitch: ");
  Serial.print(pitch);
  Serial.print("\troll: ");
  Serial.println(roll);

  RollCharacteristic.writeValue(roll);
  PitchCharacteristic.writeValue(pitch);
  HeadingCharacteristic.writeValue(heading);

  if (central) {
    while (central.connected()) {
      if (switchCharacteristic.written() && hapticState) {
        digitalWrite(LEDR, LOW);
      } else {
        digitalWrite(LEDR, HIGH);        
      }
    }
  }

}
