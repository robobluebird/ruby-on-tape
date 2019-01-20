#include <Wire.h>
#include <Servo.h>

Servo playServo;
Servo eraseServo;
Servo reverseServo;
Servo recordServo;

#define TICKS_PER_SECOND 46.0
#define FAST_TAPE_CONSTANT 8.47
#define SLOW_TAPE_CONSTANT 1.0

#define SLAVE_ADDRESS 0x04

float timeAfterUsableTapeFF = 0.63;
float timeAfterUsableTapeP = 4.9;

int number = 0;
int fastTicks = 0;
long lastFastTick = 0;
int slowTicks = 0;
long lastSlowTick = 0;
long startedTurning = -1;
int currentStep = -1;
int oldCount = 0;
int largestDelay = 0;

bool turning = false;

void (*steps[10])(void) = {NULL};

void setup() {
  clearSteps();

  Serial.begin(9600);

  pinMode(7, OUTPUT);

  Serial.begin(9600);

  while (!Serial) {}

  playServo.attach(8);
  eraseServo.attach(9);
  reverseServo.attach(10);
  recordServo.attach(11);

  delay(2000);

  standbyMode();

  Wire.begin(SLAVE_ADDRESS);
  Wire.onReceive(receiveData);
  Wire.onRequest(sendData);

  pinMode(12, OUTPUT);
  digitalWrite(12, HIGH);

  pinMode(2, INPUT);
  attachInterrupt(digitalPinToInterrupt(2), slowTick, RISING);

  pinMode(3, INPUT);
  attachInterrupt(digitalPinToInterrupt(3), fastTick, RISING);
}

void slowTick() {
  slowTicks++;
  lastSlowTick = millis();
}

void fastTick() {
  fastTicks++;
  // lastFastTick = millis();
}

void loop() {
  if (turning) {
    long now = millis();

    Serial.println(fastTicks);

//    Serial.println(fastTicks - oldCount);
//    oldCount = fastTicks;
//    delay(1000);

//    if (startedTurning != -1 && now - startedTurning > 500) {
//      if (slowTicks == 0) {
//        stopMotor();
//        standbyMode();
//        Serial.print(now - startedTurning);
//        Serial.println(" startedTurning distance is greater than 500, stopping.");
//      } else {
//        startedTurning = -1;
//        Serial.println("We have movement so set startedTurning to -1");
//      }
//    } else if (now - lastSlowTick > 1000) {
//      Serial.println(now);
//      Serial.println(lastSlowTick);
//      Serial.print(now - lastSlowTick);
//      Serial.println(" slowTick distance is greater than 1000, stopping");
//
//      stopMotor();
//      standbyMode();
//
//      if (steps[currentStep + 1] != NULL) {
//        Serial.print("Preparing to execute step ");
//        Serial.println(currentStep + 1);
//        currentStep++;
//        steps[currentStep]();
//      } else {
//        Serial.println("Finished all steps");
//        currentStep = -1;
//        clearSteps();
//      }
//    } else {
//      if (now - lastSlowTick > largestDelay) {
//        largestDelay = now - lastSlowTick;
//      }
//    }
  } else {
    if (steps[currentStep + 1] != NULL) {
      Serial.println(largestDelay);
      Serial.print("Preparing to execute step ");
      Serial.println(currentStep + 1);
      currentStep++;
      steps[currentStep]();
    }
  }

  if (Serial.available()) {
    char c = Serial.read();

    if (c == '1') {
      playMode();
    } else if (c == '2') {
      playMode2();
    } else if (c == '3') {
      fastForwardMode();
    } else if (c == '4') {
      reverseMode();
    } else if (c == '7') {
      recordMode();
    } else if (c == '5') {
      startMotor();
    } else if (c == '6') {
      stopMotor();
    } else if (c == 'l') {
      tapeLength();
    } else if (c == "s") {
      stopMotor();
      standbyMode();
    }

    // f l u s h
    while (Serial.available()) {
      Serial.read();
    }
  }
}

void tapeLength() {
  clearSteps();
  
  steps[0] = reverseMode;
  steps[1] = startMotor;
  steps[2] = fastForwardMode;
  steps[3] = startMotor;
  steps[4] = calculateLength;

  currentStep = 0;

  steps[0]();
}

void calculateLength() {
  float windTime = fastTicks / TICKS_PER_SECOND;
  float tapeTime = floor(windTime * FAST_TAPE_CONSTANT) / 60;

  Serial.print("The tape length is ");
  Serial.print(tapeTime);
  Serial.print(" minutes per side.");
  
  //Wire.write("LEN: %s", tapeLength);
}

void tapeSpeed() {
  
}

void clearSteps() {
  for (int i = 0; i < 10; i++) {
    steps[i] = NULL;
  }
}

void startMotor() {
  digitalWrite(7, HIGH);
  turning = true;
  fastTicks = 0;
  slowTicks = 0;
  lastSlowTick = millis();
  startedTurning = millis();
}

void stopMotor() {
  digitalWrite(7, LOW);
  turning = false;
}

void fastForwardMode() {
  playServo.write(60);
  eraseServo.write(60);
  reverseServo.write(90);
  recordServo.write(90);
  delay(1000);
}

void standbyMode() {
  fastForwardMode();
}

void reverseMode() {
  playServo.write(60);
  eraseServo.write(60);
  reverseServo.write(20);
  recordServo.write(90);
  delay(1000);
}

void playMode() {
  playServo.write(165);
  eraseServo.write(60);
  reverseServo.write(90);
  recordServo.write(90);
  delay(1000);
}

void playMode2() {
  playServo.write(140);
  eraseServo.write(60);
  reverseServo.write(90);
  recordServo.write(90);
  delay(1000);
}

void recordMode() {
  playServo.write(140);
  eraseServo.write(160);
  reverseServo.write(90);
  recordServo.write(70);
  delay(1000);
}

// callback for received data
void receiveData(int byteCount) {
  while (Wire.available()) {
    number = Wire.read();

    switch (number) {
      case 1:
        playMode();
        break;
      case 2:
        playMode2();
        // recordMode();
        break;
      case 3:
        fastForwardMode();
        break;
      case 4:
        reverseMode();
        break;
      case 5:
        startMotor();
        break;
      case 6:
        stopMotor();
        break;
      case 7:
        tapeLength();
      default:
        standbyMode();
        break;
    }
  }
}

// callback for sending data
void sendData() {
  Wire.write(number);
}
