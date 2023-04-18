#include <Arduino_LSM9DS1.h>
#include <Adafruit_AHRS.h>
#include <ArduinoBLE.h>
#define sensorRate 104.00
Adafruit_Mahony filter;

BLEService AHRSfilter("A123");                                              // create service
BLEFloatCharacteristic RollCharacteristic("2A19", BLERead | BLENotify);     //create Characteristic
BLEFloatCharacteristic PitchCharacteristic("2A20", BLERead | BLENotify);    //create Characteristic
BLEFloatCharacteristic HeadingCharacteristic("2A21", BLERead | BLENotify);  //create Characteristic

BLEService HapticFeedback("A124");
BLEByteCharacteristic switchCharacteristic("2A57", BLERead | BLEWrite);

//PINS
#define powerdrain 12
#define haptic 11

unsigned long start_time;
unsigned long last_connected_time;
unsigned long hapticTime;
char* deviceName = "SmartGymBros_RightForearm";
bool hapticState = false; // true means vibration is on

void setup() {
  Serial.begin(9600);
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
  //Calibration: go to https://github.com/cherking19/EC463_SmartExerciseSystem/blob/main/hardware/arduino_calibrations to see appropriate values
  // Accelerometer code
   IMU.setAccelFS(3);
   IMU.setAccelODR(5);
   IMU.setAccelOffset(0.001735, -0.012192, -0.012185);
   IMU.setAccelSlope (1.000306, 0.995948, 1.002211);
// Gyroscope code
   IMU.setGyroFS(2);
   IMU.setGyroODR(5);
   IMU.setGyroOffset (2.022766, -0.711365, -0.057831);
   IMU.setGyroSlope (1.161969, 1.147859, 1.110514);
// Magnetometer code
   IMU.setMagnetFS(0);
   IMU.setMagnetODR(8);
   IMU.setMagnetOffset(13.804932, 15.117188, 13.090820);
   IMU.setMagnetSlope (1.997173, 1.978539, 2.018379);
   
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

// BLE.setAdvertisedService(HapticFeedback);
  HapticFeedback.addCharacteristic(switchCharacteristic);
  BLE.addService(HapticFeedback);
  // BLE.advertise();
  switchCharacteristic.setEventHandler(BLEWritten, switchCharacteristicWritten);
  
  //temporary counter
  start_time = millis();
  last_connected_time=start_time;
  // pinMode(LEDR, OUTPUT); // for testing with LEDR instead of haptic
  // digitalWrite(LEDR, HIGH);
}

void switchCharacteristicWritten(BLEDevice central, BLECharacteristic characteristic) {
  digitalWrite(haptic, HIGH);
  hapticTime = millis();
  hapticState = true;
  // if (hapticState) {
  //   digitalWrite(haptic, HIGH);
  //   //delay(1000); // the delay causes the lightBlue app to not connect with the Arduino
  //   hapticState = false;
  // } else {
  //   digitalWrite(haptic, LOW);
  //   hapticState = true;
  // }
}

void loop() {
  //power control---------------
  unsigned long nowtime = millis();
 
  //----------------------------
  // Turn off vibration after 200 milliseconds
  if (hapticState) {
    if (nowtime - hapticTime > 200) {
      digitalWrite(haptic, LOW);
    }
  }

  BLEDevice central = BLE.central();
  
  //Output Values
  float roll, pitch, heading;
  //IMU values
  float xAcc, yAcc, zAcc,
        xGyro, yGyro, zGyro,
        xMag, yMag, zMag;
  if(IMU.accelerationAvailable() && IMU.gyroscopeAvailable() && IMU.magneticFieldAvailable()) {
    IMU.readAcceleration(xAcc, yAcc, zAcc);
    IMU.readGyroscope(xGyro, yGyro, zGyro);
    IMU.readMagneticField(xMag, yMag, zMag);
  }
  //update filter
  filter.update(xGyro, yGyro, -zGyro, xAcc, yAcc, -zAcc, -xMag, yMag, -zMag);
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
  if(BLE.connected()){
    Serial.println("CONNECtED");
    last_connected_time=nowtime;

  }
  else
    // Serial.println("NOT CONNECTED");
    if(nowtime-last_connected_time > 30000){
      Serial.println("NOT CONNECTED FOR 30 SECONDS. POWERING OFF");
      digitalWrite(powerdrain, HIGH);
    }
}
