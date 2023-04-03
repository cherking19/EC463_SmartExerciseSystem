#define powerdrain 12
#define haptic 11
unsigned long start_time;
void setup() {
  // put your setup code here, to run once:
  pinMode(powerdrain, OUTPUT);
  pinMode(haptic, OUTPUT);
  digitalWrite(powerdrain, LOW);
  digitalWrite(haptic, LOW);
  start_time = millis();
}

void loop() {
  unsigned long nowtime=millis();
  if ( nowtime - start_time >= 10000)
    digitalWrite(powerdrain, HIGH);
  
  if(nowtime%1000 < 400)
    digitalWrite(haptic,HIGH);
  else
    digitalWrite(haptic,LOW);
  
   Serial.print(String(nowtime));
   Serial.print("\n");
}
