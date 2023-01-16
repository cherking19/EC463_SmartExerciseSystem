#define powerdrain 12
#define haptic 11
unsigned long start_time;
void setup() {
  // put your setup code here, to run once:
  pinMode(powerdrain, OUTPUT);
  pinMode(haptic, OUTPUT);
//  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(powerdrain, LOW);
  digitalWrite(haptic, LOW);
//  digitalWrite(LED_BUILTIN, LOW);
  // Serial.begin(9600);
  start_time = millis();
  

  //counter
  

  //endcounter
}

void loop() {
  unsigned long nowtime=millis();
  if ( nowtime - start_time >= 3000)
    digitalWrite(powerdrain, HIGH);
  
  if(nowtime%1000 < 400)
    digitalWrite(haptic,HIGH);
  else
    digitalWrite(haptic,LOW);
  
  // Serial.print(String(nowtime));
  // Serial.print("\n");
}
