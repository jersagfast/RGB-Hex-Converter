 // this library is from Lady Ada, it can be downloaded here: https://github.com/adafruit/PCD8544-Nokia-5110-LCD-library
 // you can also buy this LCD from adafruit.com here: http://www.adafruit.com/products/338
 // sketch by Jeremy Saglimbeni thecustomgeek.com - 2011
#include "PCD8544.h"
#include <EEPROM.h>
PCD8544 nokia = PCD8544(13, 12, 8, 7, 5);
int redup = 16; // red up button
int redupv = 0;
int reddn = 4; // red down button
int reddnv = 0;
int grnup = 17; // green up button
int grnupv = 0;
int grndn = 2; // green down button
int grndnv = 0;
int bluup = 18; // blue up button
int bluupv = 0;
int bludn = 14; // blue down button
int bludnv = 0;
int halfbtn = 19; // half value button
int halfbtnv = 0;
int resetbtn = 15; // reset button
int resetbtnv = 0;
int lcdbl = 6; // LCD backlight
int redled = 9; // red LED
int grnled = 10; // green LED
int bluled = 11; // blue LED
int i = 0;
int redv = 0;
int grnv = 0;
int bluv = 0;
long battv = 0;
long prevbatt = 0;
char red [33];
char green [33];
char blue [33];
unsigned long currenttime;
unsigned long battcheck = 10000; // time between battery checks in ms
unsigned long answer;
char output[10];
long readVcc() {
  long result;
  // Read 1.1V reference against AVcc
  ADMUX = _BV(REFS0) | _BV(MUX3) | _BV(MUX2) | _BV(MUX1);
  delay(2); // Wait for Vref to settle
  ADCSRA |= _BV(ADSC); // Convert
  while (bit_is_set(ADCSRA,ADSC));
  result = ADCL;
  result |= ADCH<<8;
  result = 1126400L / result; // Back-calculate AVcc in mV
  return result;
}
void setup() {
  pinMode(resetbtn, INPUT);
  pinMode(halfbtn, INPUT);
  pinMode(redup, INPUT);
  pinMode(reddn, INPUT);
  pinMode(grnup, INPUT);
  pinMode(grndn, INPUT);
  pinMode(bluup, INPUT);
  pinMode(bludn, INPUT);
  pinMode(lcdbl, OUTPUT);
  digitalWrite(resetbtn, HIGH);
  digitalWrite(halfbtn, HIGH);
  digitalWrite(redup, HIGH);
  digitalWrite(reddn, HIGH);
  digitalWrite(grnup, HIGH);
  digitalWrite(grndn, HIGH);
  digitalWrite(bluup, HIGH);
  digitalWrite(bludn, HIGH);
  for(i = 0 ; i <= 255; i+=1) { 
    analogWrite(lcdbl, i);
    delay(3);
  }
  nokia.init();
  nokia.command(PCD8544_DISPLAYCONTROL | PCD8544_DISPLAYALLON);
  nokia.command(PCD8544_DISPLAYCONTROL | PCD8544_DISPLAYNORMAL);
  nokia.clear();
  nokia.drawstring(3, 2, "thecusomgeek");
  nokia.drawstring(27, 3, ".com");  
  nokia.display();
  delay(2000);
  nokia.clear();
  nokia.drawstring(0, 0, "RGB to 5:6:5");
  nokia.drawstring(0, 1, "HEX Converter");
  nokia.drawstring(0, 2, "(c)2011 Jeremy");
  nokia.drawstring(0, 3, "    Saglimbeni");
  nokia.drawline(0, 36, 83, 36, BLACK);
  nokia.drawstring(0, 5, "SW 1.0 HW 1.2");
  nokia.display();
  delay(3000);
  nokia.clear();
  nokia.drawrect(71, 1, 10, 4, BLACK);
  nokia.fillrect(81, 2, 1, 2, BLACK);
  nokia.drawstring(0, 0, "RGB to HEX");
  nokia.drawline(0, 10, 83, 10, BLACK);
  nokia.drawstring(0, 2, "Red:");
  itoa (redv, red, 10);
  nokia.drawstring(0, 3, "Green:");
  nokia.drawstring(60, 3, blue);
  nokia.drawstring(0, 4, "Blue:");
  nokia.drawstring(60, 2, "0");
  nokia.drawstring(60, 3, "0");
  nokia.drawstring(60, 4, "0");
  itoa (grnv, green, 10);
  nokia.drawstring(0, 5, "HEX:    0x0");
  nokia.display();
  batt();
}
void loop() {
  currenttime = millis();
  resetbtnv=digitalRead(resetbtn);
  halfbtnv=digitalRead(halfbtn);
  redupv=digitalRead(redup);
  reddnv=digitalRead(reddn);
  grnupv=digitalRead(grnup);
  grndnv=digitalRead(grndn);
  bluupv=digitalRead(bluup);
  bludnv=digitalRead(bludn);
  if (redupv == LOW) { // when red up button is pushed
    redv++; // increase the red value by 1
    if (redv >= 255) { // don't let the value go over 255
      redv = 255;
    }
    itoa (redv, red, 10); // change the numeric value into a string
    nokia.drawstring(60, 2, red); // print the string
    nokia.display(); // write to the display
    analogWrite(redled, redv); // write the value to the LED
    showhex(); // do/show the HEX conversion with the new value
}
if (reddnv == LOW) {  // when red down button is pushed
    redv--; // increase the red value by 1
    if (redv <= 0) { // don't let the value go below 
      redv = 0;
    }
    itoa (redv, red, 10); // change the numeric value into a string
    nokia.drawstring(60, 2, red); // print the string
    if (redv < 100) { // when the value goes from 100 to 99, erase the last digit
        nokia.drawstring(72, 2, " ");
      }
      if (redv < 10) {// when the value goes from 10 to 9, erase the last digit
        nokia.drawstring(66, 2, " ");
      }
    nokia.display(); // write to the display
    analogWrite(redled, redv); // write the value to the LED
    showhex(); // do/show the HEX conversion with the new value
}
if (grnupv == LOW) {
    grnv++;
    if (grnv >= 255) {
      grnv = 255;
    }
    itoa (grnv, green, 10);
    nokia.drawstring(60, 3, green);
    nokia.display();
    analogWrite(grnled, grnv);
    showhex();
  }
  if (grndnv == LOW) {
    grnv--;
    if (grnv <= 0) {
      grnv = 0;
    }
    itoa (grnv, green, 10);
    nokia.drawstring(60, 3, green);
    if (grnv < 100) {
        nokia.drawstring(72, 3, " ");
      }
      if (grnv < 10) {
        nokia.drawstring(66, 3, " ");
      }
    nokia.display();
    analogWrite(grnled, grnv);
    showhex();
  }
  if (bluupv == LOW) {
    bluv++;
    if (bluv >= 255) {
      bluv = 255;
    }
    itoa (bluv, blue, 10);
    nokia.drawstring(60, 4, blue);
    nokia.display();
    analogWrite(bluled, bluv);
    showhex();
  }
  if (bludnv == LOW) {
    bluv--;
    if (bluv <= 0) {
      bluv = 0;
    }
    itoa (bluv, blue, 10);
    nokia.drawstring(60, 4, blue);
    if (bluv < 100) {
        nokia.drawstring(72, 4, " ");
      }
      if (bluv < 10) {
        nokia.drawstring(66, 4, " ");
      }
    nokia.display();
    analogWrite(bluled, bluv);
    showhex();
  }
if (resetbtnv == LOW) { // when the reset button is pressed
  redv = 0; // reset all the values to 0
  grnv = 0;
  bluv = 0;
  nokia.drawstring(60, 2, "0  "); // erase and reset the values to 0
  nokia.drawstring(60, 3, "0  ");
  nokia.drawstring(60, 4, "0  ");
  nokia.display();
  analogWrite(redled, bluv); // write the new values to the LED
  analogWrite(grnled, grnv);
  analogWrite(bluled, bluv);
  showhex(); // update the HEX display
}
if (halfbtnv == LOW) { // when the reset button is pressed
  redv = 128; // reset all the values to 0
  grnv = 128;
  bluv = 128;
  nokia.drawstring(60, 2, "128"); // erase and reset the values to 0
  nokia.drawstring(60, 3, "128");
  nokia.drawstring(60, 4, "128");
  nokia.display();
  analogWrite(redled, redv); // write the new values to the LED
  analogWrite(grnled, grnv);
  analogWrite(bluled, bluv);
  showhex();
}

if(currenttime - prevbatt > battcheck) { // check the voltage/update battery icon
    batt();
    prevbatt = currenttime;
}
}
void showhex() { // convert the 8:8:8 RGB values to 5:6:5 HEX
  answer = ((redv / 8) << 11) | ((grnv / 4) << 5) | (bluv / 8);
  itoa (answer, output, HEX);
  nokia.drawstring(60, 5, "    ");
  nokia.drawstring(60, 5, output);
  nokia.display();
}
void batt() { // check/graph batt voltage
     battv = readVcc();
  if (battv > 4000) {
    nokia.drawrect(72, 2, 8, 2, BLACK);
    nokia.drawrect(80, 2, 1, 2, BLACK);
    nokia.display();
  }
  if (battv > 3900 && battv < 4000) {
    nokia.drawrect(72, 2, 7, 2, BLACK);
    nokia.drawrect(80, 2, 1, 2, WHITE);
    nokia.display();
  }
  if (battv > 3800 && battv < 3900) {
    nokia.drawrect(72, 2, 6, 2, BLACK);
    nokia.drawrect(79, 2, 2, 2, WHITE);
    nokia.display();
  }
  if (battv > 3700 && battv < 3800) {
    nokia.drawrect(72, 2, 5, 2, BLACK);
    nokia.drawrect(78, 2, 3, 2, WHITE);
    nokia.display();
  }
  if (battv > 3600 && battv < 3700) {
    nokia.drawrect(72, 2, 4, 2, BLACK);
    nokia.drawrect(77, 2, 4, 2, WHITE);
    nokia.display();
  }
  if (battv > 3500 && battv < 3600) {
    nokia.drawrect(72, 2, 3, 2, BLACK);
    nokia.drawrect(76, 2, 5, 2, WHITE);
    nokia.display();
  }
  if (battv > 3400 && battv < 3500) {
    nokia.drawrect(72, 2, 2, 2, BLACK);
    nokia.drawrect(75, 2, 6, 2, WHITE);
    nokia.display();
  }
  if (battv > 3300 && battv < 3400) {
    nokia.drawrect(72, 2, 1, 2, BLACK);
    nokia.drawrect(74, 2, 7, 2, WHITE);
    nokia.display();
  }
  if (battv < 3300) {
    nokia.drawrect(72, 2, 8, 2, BLACK);
    nokia.drawrect(73, 2, 8, 2, WHITE);
    nokia.display();
  }
}
