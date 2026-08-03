

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

# 2026-06-19 First Draft

## For Controlling the light (red=on, white=brake)

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


## For Controlling the power to ATtiny85 (

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

# 2026-06-20 Second Draft

After looking more closely at some of the spec, and some Kicad simulation, I realized that I need different parts.
The mosfets should be a 'logical' variant, so that they can fully trigger from the 4.5v rather than a 10v signal.
The power input circuit can use a couple of diodes to act as the OR gate providing 4.5v (from bike) or 5v (from buck) to the ATtiny.
I want to turn the brakelight into an actual cable.

For development, I want a breadboard and power circuit

| Part           | Needed | Purchased | Cost | Description                     |
|----------------|--------|-----------|------|---------------------------------|
| IRL540N        |      2 |         5 | 2.41 | N-type Mosfet, 100V 33A         |
| BAT85          |      2 |        50 | 1.68 | Schottky Diode D0-35            |
| M6 5pin cable  | 1m 1f  |    1 pair | 3.04 | male & female cable pair        |
| ZY12PDN        |      1 |         1 | 2.02 | USB-C power with post terminals |
| breadboard     |      1 |         5 | 2.53 | solderable, various sizes       |

These changes obsolete some parts already purchased:
 - IRF540N, 2N2222

Also realized that I need to get some breakaway header pins + socket so the ATtiny can be removed for programming.
And KF2510 connectors + sockets to make the eBike + brake cables pluggable, board removable.

## Models

* https://github.com/yasir-shahzad/Digispark-ATTINY85
  has 3D and schematics for the board!

## More Revisions

Then I figured out that I need the circuit to be a high-side control, because the brake light has common ground.
The 2N2222 transistors are only rated for 40V, so now they are not suitable (but already purchased).
And some other parts: like flux rosin, header pins, and connector cables.

* [12v arduino high-side circuit](https://europe1.discourse-cdn.com/arduino/original/4X/a/4/9/a492336dbcc6dfbb94111606fce4d31aaf3bd7c3.jpeg)
* [48v arduino high-side circuit](https://www.reddit.com/r/AskElectronics/comments/1lqwbhb/drive_pchannel_mosfet_switching_48v_with_3v3/)

| Part              | Needed | Purchased  | Cost | Description              |
|-------------------|--------|------------|------|--------------------------|
| IRL540N           | Remove |            |      | N-type Mosfet, 100V 33A  |
| 2N5551            |      2 |         25 | 1.33 | NPN transistors (100V)   |
| FQP27P06          |      2 |         10 | 3.10 | P-Type Mosfet, -60V -27A |
| KF2510 kit        |      1 |         40 | 2.83 | connect kit for cables   |
| Female SMD socket |   9pin | 40pin * 10 | 2.82 | 2.54mm socket pins       |


## Yet More Revisions

The buck converter requires a constant HIGH signal on the "enable" pin to stay off.
Consequently, I have to make a suicide circuit to control the 48v input to the converter.
It needs another mosfet (got extras) and transistors (extras) and resistors (extras).
We no longer need the diodes!

| Part   | Needed | Purchased  | Cost | Description              |
|--------|--------|------------|------|--------------------------|
| BAT85  | Remove |            |      | Schottky Diode D0-35     |

# 2026-06-21

Found a KiCAD model for the ATtiny
 * [swww1235](https://github.com/sww1235/KiCAD-Libraries/tree/master/SW-Digistump.pretty)

# 2026-07-02

## Software

Attempted to use a snap package
 - wants 32 bit libs during compilation step.
Attempted to use a deb package
 - could not install, don't know why
Attempted to use the official digistump package
 - but the micronucleus is too old (cannot locate device on usb)

Fortunately, is easy to clear state by `rm -rf ~/.arduino15`


Install
```
wget https://github.com/arduino/arduino-cli/releases/download/v1.5.1/arduino-cli_1.5.1-1_amd64.deb
sudo apt install ./arduino-cli_1.5.1-1_amd64.deb
sudo apt install libusb-1.0-0-dev # for the newer micronucleus
```

Setup (had to pick a version with modern micronucleus)
```
old_url="https://raw.githubusercontent.com/digistump/arduino-boards-index/master/package_digistump_index.json"
url="https://raw.githubusercontent.com/ArminJo/DigistumpArduino/master/package_digistump_index.json"
arduino-cli config set board_manager.additional_urls $url
arduino-cli core update-index
arduino-cli core install digistump:avr
```

Additional Steps: Did not know about the usb assignment
```
Copy https://github.com/micronucleus/micronucleus/blob/master/commandline/49-micronucleus.rules
To /etc/udev/rules.d
sudo udevadm control --reload-rules
```

Arduino expects that the code file is a dir of the same name.

Program, `cd code`
Do not plug it in until prompted by the 'upload' step
```
arduino-cli compile --fqbn digistump:avr:digispark-tiny code.ino
arduino-cli upload --fqbn digistump:avr:digispark-tiny code.ino
```

# 2026-07-16 Circuit Debugging, Broken ATtiny

Was trying to debug the circuit and made some important discoveries:
 - I thought that the VIN

Some of the pins are not available for me to use as a sensor. Specifically, I
cannot have anything on PB5, because that's the RESET pin for the ATTiny. It
won't boot (will be held in reset) if it senses anything.

So new wiring:

| Pin | Code | Purpose |
|-----|------|---------|
|  6  | PB5  | Unused - leave disconnected so chip can boot |
|  5  | PB4  | PWR_CONTROL - drives the power input transistor Q6 |
|  4  | PB3  | Unused - leave disconnected to avoid the 1.5k USB pull-up resistor conflict |
|  3  | PB2  | BRAKE_LIGHT |
|  2  | PB1  | TAIL_LIGHT |
|  1  | PB0  | SYS_PWR_READ - reads the brake line via 10k resistor |

Also I think I broke the chip by over-voltaging it. The board has its own power
regulator, but I was really confused about which pin that would be. I supplied
7.5v to the Vin pin of the ATTiny (online it said to use between 7v and 12v).

To avoid burning out the ATTiny in the future check:
1. "Resistance-to-Rail"
   power off, no chip
   measure PB4 to BATT, expect: open loop
   measure PB4 to SYS, expect: open loop
   measure PB4 to Mosfet Q4 (pwr control), expect: R9+R7+R6 (high resistance)
2. "Inline Current Limiting"
   power off, no chip
   confirm 10k R9 sits between PB4 and transistor Q6 base
   measure PB4 to base of Q6, expect: 10k
3. "Safe Simulation"
   power on, no chip
   measure volts on PB4, expect: 0v (because no driver)
   pull up test, connect PB4 to 5v with 10k resistor
     should activate Q6, Q5, Q4, turning on SYS power
   measure current flowing through tmp resistor or check that PB4 stays stable near 5v
4. "Code Safety Rule"
   always declare pin mode as OUTPUT, before attempting any digitalWrite
   avoid rapid toggling at boot in setup(), wait a sec for USB handshake to finish

Consider setting PB4 mode as INPUT_PULLUP, expecting the brake to override it

# 2026-07-26 Box Design

Major PITA.
Also, did not leave enough room for the ATTiny. Ugh!
So used the entire! day redrawing the box and lid

# 2026-08-01 Assembly on the bike

I got the brake & tail lights wired in wrong.
Swapping the pins on the molex worked.

It sparks when I plug it in. After that it doesn't turn off.

# 2026-08-02 Circuit Adjustments

At lower voltages, ~20v the circuit operates as expected.
But then at higher voltages, ~50v BATT, it fries the mosfet.

Attempted to put a zener diode across the Gate & Source, but that did not work.
I think that we can use the enable/disable pin on the buck converter instead.
Worked with Gemini to come up with a new circuit for that.



