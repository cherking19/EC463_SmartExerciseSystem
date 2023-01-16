#include <Arduino_LSM9DS1.h>
#include <Adafruit_AHRS.h>
#include <Adafruit_Sensor_Calibration.h>
#define sensorRate 104.00
Adafruit_Mahony filter;
#if defined(ADAFRUIT_SENSOR_CALIBRATION_USE_EEPROM)
  Adafruit_Sensor_Calibration_EEPROM cal;
#else
  Adafruit_Sensor_Calibration_SDFat cal;
#endif

template <typename T>
Print& operator<<(Print& printer, T value)
{
    printer.print(value);
    return printer;
}

void setup() {
  Serial.begin(9600);
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
  //Output Values
  float roll, pitch, heading;
  //IMU values
  float xAcc, yAcc, zAcc,
        xGyro,yGyro,zGyro,
        xMag, yMag, zMag;
  if(IMU.accelerationAvailable() && 
      IMU.gyroscopeAvailable() &&
      IMU.magneticFieldAvailable()) {
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
  // Serial << "xa:\t"<<xAcc<<"ya:\t"<<yAcc<<"za:\t"<<zAcc<<'\n';
  // Serial << "xg:\t"<<xGyro<<"yg:\t"<<yGyro<<"zg:\t"<<zGyro<<'\n';
  // Serial << "xm:\t"<<xMag<<"ym:\t"<<yMag<<"zm:\t"<<zMag<<'\n';

  // Serial.print("Orientation: ");
  // Serial.print(heading);
  // Serial.print(", ");
  // Serial.print(pitch);
  // Serial.print(", ");
  // Serial.println(roll);
  Serial << "heading: "<<heading<<", pitch: "<<pitch<<", roll: "<<roll<<"\n";
  // delay(500);
}
