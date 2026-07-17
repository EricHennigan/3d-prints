
// Pin assignments                Digispark silkscreen labels
const int PIN_BRAKE_SENSE = PB0; // brake input (LOW = engaged)
const int PIN_LED         = PB1;
const int PIN_TAIL_LIGHT  = PB1; // tail light output
const int PIN_BRAKE_LIGHT = PB2; // brake light output
const int PIN_POWER       = PB4; // power control


// TESTING
void setup() {
  pinMode(PIN_BRAKE_SENSE, INPUT);
  pinMode(PIN_TAIL_LIGHT, OUTPUT);
  pinMode(PIN_BRAKE_LIGHT, OUTPUT);
  pinMode(PIN_POWER, OUTPUT);

  digitalWrite(PIN_POWER, HIGH);
}

void loop() {
  static int counter = 0;
  counter++;
  if (counter > 30) digitalWrite(PIN_POWER, LOW);

  bool braking = (digitalRead(PIN_BRAKE_SENSE) == LOW);
  pinMode(PIN_BRAKE_LIGHT, braking);

  delay(1500);
}

/* DESIRED BRAKE PROGRAM

// Timing
const unsigned long POLL_INTERVAL_MS = 20; // 50Hz
const unsigned long BRAKE_TIMEOUT_MS = 60000UL; // 1 minute
unsigned long shutDownTime = 0;

void setup() {
 shutDownTime = millis() + BRAKE_TIMEOUT_MS;

 pinMode(PIN_TAIL_LIGHT,  OUTPUT);
 pinMode(PIN_BRAKE_LIGHT, OUTPUT);
 pinMode(PIN_BRAKE_SENSE, INPUT);
 pinMode(PIN_POWER,       OUTPUT);

 // Set initial lights and toggle power state
 digitalWrite(PIN_TAIL_LIGHT, HIGH);
 digitalWrite(PIN_BRAKE_LIGHT, LOW);
 digitalWrite(PIN_POWER, HIGH);
}


void loop() {
  bool braking = (digitalRead(PIN_BRAKE_SENSE) == LOW);

  // update the brake light
  digitalWrite(PIN_BRAKE_LIGHT, braking);

  // system has been shut off (or break engaged for too long)
  if (braking && millis() > shutDownTime) {
    digitalWrite(PIN_POWER, LOW);
  }

  // brake released, delay the system shutoff
  if (!braking) {
    shutDownTime = millis() + BRAKE_TIMEOUT_MS;
  }

  delay(POLL_INTERVAL_MS);
}
*/
