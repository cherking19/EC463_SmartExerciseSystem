#define powerdrain 12
unsigned long start_time;
void setup() {
  // put your setup code here, to run once:
  pinMode(powerdrain, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(powerdrain, LOW);
  digitalWrite(LED_BUILTIN, LOW);
  start_time = millis();
}

void loop() {
  // put your main code here, to run repeatedly:
  if (millis() - start_time >= 3000){
    digitalWrite(powerdrain, HIGH);
    digitalWrite(LED_BUILTIN, HIGH);
  }
}
