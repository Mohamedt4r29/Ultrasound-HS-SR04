# Ultrasonic Distance Measurement System (VHDL on FPGA)

This project implements an ultrasonic distance measurement system using VHDL on the Nexys A7 FPGA board. It simulates how an HC-SR04 ultrasonic sensor measures distance using periodic trigger pulses, echo signal detection, and timing logic to calculate and display the distance in centimeters.

---


## 📦 Project Overview

This system periodically sends a 10µs trigger pulse to an ultrasonic sensor. When the sensor detects a reflected echo, the system measures how long the echo signal stays high and uses that timing to calculate the distance to the object.

The final output is a real-time distance value, calculated from the number of clock cycles the echo signal was high. The design is written entirely in VHDL and tested via simulation in Vivado.

---

## 🧱 Module Breakdown

| Module Name          | Description |
|----------------------|-------------|
| `trigger_generator`  | Generates periodic 10µs pulses to trigger the ultrasonic sensor |
| `echo_detector`      | Detects rising/falling edges of the echo signal and measures pulse width |
| `distance_calculator`| Converts the echo duration (in clock cycles) into distance in cm |
| *(Optional)* `top_level` | Connects all modules together in a single design |

---

## 🔁 How It Works

1. `trigger_generator` creates a HIGH pulse (10µs long) every 10ms.
2. The sensor sends back an `echo` signal — high for a time proportional to object distance.
3. `echo_detector` counts clock cycles while echo is high.
4. `distance_calculator` divides the result by 58 to convert it to distance in centimeters.

---

## 🧪 Simulation Results

- All components were tested using VHDL testbenches in Vivado.
- The waveform shows:
  - `trigger` pulses every 10ms
  - `echo` pulse durations
  - `echo_time` should measured correctly
  - `distance_cm` output should match expected results

---

## 🛠 Tools Used

- Vivado (for simulation and synthesis)
- VHDL (code + testbenches)
- Nexys A7 Board 

---

## 📷 Screenshots



## 📁 Folder Structure

