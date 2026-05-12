#include <Servo.h>

Servo servo1;
String gelenVeri;

void setup() {
  Serial.begin(9600); 
  servo1.attach(9);   
  
  servo1.write(90);
}

void loop() {
  if (Serial.available() > 0) {
    gelenVeri = Serial.readStringUntil('\n'); 
    
    if (gelenVeri.startsWith("S1:")) {
      int aci = gelenVeri.substring(3).toInt();
      servo1.write(aci);
      Serial.println("OK:S1"); 
    } 
  }
}