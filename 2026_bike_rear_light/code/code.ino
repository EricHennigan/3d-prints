
// Pin assignments                Digispark silkscreen labels
const int PIN_TAIL_LIGHT  = 1; // PB1 — tail light output
const int PIN_BRAKE_LIGHT = 2; // PB2 — brake light output
const int PIN_BRAKE_SENSE = 3; // PB3 — brake input (LOW = engaged)
const int PIN_POWER       = 5; // PB5 — power control

// Timing
const unsigned long POLL_INTERVAL_MS = 20; // 50Hz
const unsigned long BRAKE_TIMEOUT_MS = 60000UL; // 1 minute
unsigned long shutDownTime = 0;

void setup() {
 shutDownTime = millis() + BRAKE_TIMEOUT_MS;

 pinMode(PIN_TAIL_LIGHT,  OUTPUT);
 pinMode(PIN_BRAKE_LIGHT, OUTPUT);
 pinMode(PIN_BRAKE_SENSE, INPUT_PULLUP);
 pinMode(PIN_POWER,       OUTPUT);

 digitalWrite(PIN_TAIL_LIGHT, HIGH);  // tail light on at boot
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

