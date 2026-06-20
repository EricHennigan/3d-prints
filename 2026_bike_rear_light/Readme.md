
# Parts List

| Part           | Needed | Purchased | Cost | Description                           |
|----------------|--------|-----------|------|---------------------------------------|
| IRF540N        |      3 |         5 | 3.26 | N-type Mosfet, 100V 33A               |
| LM2596HV       |      1 |         1 | 1.35 | DC-DC Buck Converter 4.5-50V to 3-35V |
| M6 4pin female |      1 |         1 | 2.53 | Cable connection                      |
| ATtiny85       |      1 |         1 | 3.37 | Microcontroller                       |
| Resistors      |      ? |       300 | 2.52 | Box of resistors                      |
| 2N2222         |      1 |        50 | 1.50 | Latch transistor                      |
| Breadbord      |      1           1 | 2.16 | MB-102 830pts Breadboard              |

# Design

Measured the LED breaklight at 75mA, so it has high-ish voltage, but little current


# For Controlling the light (red=on, white=brake)

```
+50V  ───── Lamp ───── Drain   IRF540N   Source ───── 0V/GND
                          |
ATtiny85 pin ── 100Ω ── Gate
                          |
                        10kΩ
                          |
                        GND
```

Note: should use a larger resistor >300Ω to limit ~20mA from ATtiny85

* https://www.instructables.com/ArduinoMicrocontroller-MOSFET/
* [Arduino IRF540 Mosfetf](https://www.youtube.com/watch?v=BPyV6fDcEiw&t=3s)


# For Controlling the power to ATtiny85 (

Power section
 * 50 V always-on input to LM2596HV IN+ / IN-.
 * LM2596HV set to 5.0 V output.
 * LM2596HV 5 V output powers the ATtiny85 VCC.
 * Common ground between 50 V source, LM2596HV, ATtiny85, and the 4.5 V trigger source.

Trigger input
 * Feed the 4.5 V signal into an ATtiny85 input pin through a series resistor, for example 10 kΩ.
 * Add a 100 kΩ pulldown on that input so it reads low when the bicycle/brake signal disappears.
 * If the 4.5 V line is noisy, add a 0.1 µF capacitor to ground for filtering.

Latch switch using IRF540N (low-side master switch for buck converter ground return)
 * 50 V supply negative goes to IRF540N drain.
 * IRF540N source goes to system ground and LM2596HV IN-.
 * ATtiny85 output drives the gate through 270 Ω.
 * Gate has a 100 kΩ pull-down to source.

When the ATtiny85 turns the MOSFET on, the LM2596HV gets its ground reference and powers up. When the ATtiny85 turns it off, the converter loses ground and the whole controller shuts down.

If your LM2596HV module has an EN pin, that is better than switching its ground. In that case:
 * Keep 50 V on the converter input all the time.
 * Use the ATtiny85 to hold EN active after startup.
 * Read the 4.5 V trigger on an input pin.
 * After 1 minute of trigger absence, drive EN inactive.
That avoids interrupting the converter ground and is cleaner if your module supports it

The most reliable version with your parts is:
 * LM2596HV makes 5 V for the ATtiny85.
 * ATtiny85 reads the 4.5 V line.
 * ATtiny85 drives the IRF540N gate.
 * IRF540N either switches the LM2596HV ground or, preferably, an enable stage if your converter module has one.

* [5 Soft Latching Power Circuits](https://www.youtube.com/watch?v=7D9L9oS4AJM&t=1s)
* https://electronics.stackexchange.com/questions/81935/mosfet-usage-and-p-vs-n-channel

```
                 +50V always-on
                      |
                      +-----------------------> LM2596HV IN+
                      |
                     GND ---------------------> LM2596HV IN-

LM2596HV OUT+ -------------------------------> ATtiny85 pin 8 (VCC)
LM2596HV OUT- -------------------------------> ATtiny85 pin 4 (GND)

4.5V trigger signal
      |
     10k
      |
      +--------------------------------------> ATtiny85 pin 7 (PB2) or pin 5 (PB0)
      |
    100k
      |
     GND
      |
    0.1uF
      |
     GND


ATtiny85 pin 6 (PB1) ---- 1k to 4.7k ----> 2N2222 base
2N2222 emitter ---------------------------> GND
2N2222 collector ---- 100Ω ----+---------> IRF540N gate
                               |
                              100k
                               |
                              GND

IRF540N source ---------------------------> GND
IRF540N drain ----------------------------> switched return node
```
