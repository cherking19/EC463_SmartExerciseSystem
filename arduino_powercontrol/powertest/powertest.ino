#define powerdrain 12
#define haptic 13
unsigned long start_time;
void setup() {
  // put your setup code here, to run once:
  pinMode(powerdrain, OUTPUT);
  pinMode(haptic, OUTPUT);
//  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(powerdrain, LOW);
  digitalWrite(haptic, LOW);
//  digitalWrite(LED_BUILTIN, LOW);
  Serial.begin(9600);
  start_time = millis();
  

  //counter
  

  //endcounter
}

void loop() {
  // put your main code here, to run repeatedly:
  if (millis() - start_time >= 3000){
    digitalWrite(powerdrain, HIGH);
//    digitalWrite(LED_BUILTIN, HIGH);
  }
  if(millis()%1000 < 400)
    digitalWrite(haptic,HIGH);
  else
    digitalWrite(haptic,LOW);
  Serial.print(String(millis()));
  Serial.print("\n");
}
