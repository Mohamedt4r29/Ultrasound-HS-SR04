# **Ultrasonic Distance Measurement Project**

## **Introduction**
The Nexys A7 FPGA board controls the HC-SR04 ultrasonic sensor to measure distances. The HC-SR04 connects to the FPGA using VCC (5V), GND, Trig (to FPGA for a 10 µs pulse), and Echo (to Arduino UNO for signal reading). The Arduino sends the Echo signal to the FPGA. A 1kΩ resistor adjusts the Echo signal voltage, and a 470Ω resistor regulates the current. A breadboard and connecting wires link everything together, so the FPGA can calculate the distance and display it on a 7-segment display.

## **Project Aim**
*(To be filled later)*

## **Team Members**
- **Mohamed**: Responsible for VHDL coding, hardware setup, and system integration.
- **Filip**: Assisted with documentation, researched the HC-SR04 sensor, and helped with the theoretical foundation of the project.

## **Hardware Schema Section**
### **Hardware Connection Schema**
The Nexys A7 FPGA board controls the HC-SR04 ultrasonic sensor for distance measurement. The HC-SR04 connects via VCC (5V), GND, Trig (to FPGA for a 10 µs pulse), and Echo (to Arduino UNO for signal reading). The Arduino sends the Echo signal to the FPGA. A 1kΩ resistor adjusts the Echo signal voltage, and a 470Ω resistor regulates the current. A breadboard and connecting wires link all parts, enabling the FPGA to calculate and display distance on a 7-segment display.

![Hardware Schema](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/schematics/Hardware%20Connection%20Schema.jpg)

---

## **1. Trigger Generator (`trigger_gen.vhd`) Documentation**

### **Code Explanation**
The **trigger_gen.vhd** file generates a `trig` signal for the HC-SR04 sensor to start measuring distance. It makes the `trig` signal **high for 10 microseconds** and **low for 60 milliseconds**, controlled by a **100 MHz clock**. The counter counts to **1,000** for 10 µs and **6,000,000** for 60 ms, repeating the cycle. The `reset` signal resets the counter and `trig` signal to 0 when active.

For the full code, refer to the [trigger_gen.vhd](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/src/trigger_gen.vhd) file.

### **Testbench Explanation**
The **trigger_gen_tb.vhd** testbench checks if the `trig` signal stays high for **10 µs** and low for **60 ms**, and verifies the timing using “assert” to ensure no errors.

For the full testbench code, refer to the [trigger_gen_tb.vhd](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/testbenches/tb_trigger_gen.vhd) file.

### **Waveform Explanation**
The **trigger_gen** waveform shows `clk`, `reset`, and `trig`. After **20 ns** of reset, the `trig` signal stays high for **10 µs** and low for **60 ms**. This cycle repeats every time the `clk` ticks.

![Trig Pulse Waveform](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/Waveform%20Screenshot/Trig%20pulse%20screenshot.png)

---

## **2. Echo Processor (`echo_proc.vhd`) Documentation**

### **Code Explanation**
The **echo_proc.vhd** file calculates the distance based on the `echo` signal. It counts how long the `echo` stays high. For a distance of **1 m**, it counts **582,000 ticks**, and for **0.5 m**, it counts **291,000 ticks**. If `echo` is high for more than **50 ms**, the distance is set to 0.

For the full code, refer to the [echo_proc.vhd](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/src/echo_proc.vhd) file.

### **Testbench Explanation**
The **echo_proc_tb.vhd** testbench tests the distance calculation by sending `echo` signals for distances of **1 m**, **0.5 m**, and a timeout of **60 ms**. It checks if the calculated distances are correct.

For the full testbench code, refer to the [echo_proc_tb.vhd](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/testbenches/tb_echo_proc.vhd) file.

### **Waveform Explanation (First Image)**
The first **echo_proc** waveform shows `clk`, `reset`, `echo`, and `distance`. The `echo` signal stays high for **5,820 µs** (1 m), and the `distance` is calculated as **998 mm**.

![Echo Processor Waveform](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/Waveform%20Screenshot/Echo%20screenshot.png)

### **Waveform Explanation (Second Image)**
The second **echo_proc** waveform shows `clk`, `echo`, and `distance`. After **2,910 µs** (0.5 m), the `distance` becomes **499 mm**, and after a **60 ms** timeout, `distance` is reset to 0.

![Echo Processor Waveform](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/Waveform%20Screenshot/Echo%20screenshot.png)

---

## **3. Display Controller (`disp_ctrl.vhd`) Documentation**

### **Code Explanation**
The **disp_ctrl.vhd** file controls the display of the `distance` on a 7-segment display. It converts the **16-bit `distance`** into BCD digits using the double-dabble method. It uses a refresh counter that switches the display every **1 ms**.

For the full code, refer to the [disp_ctrl.vhd](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/src/disp_ctrl.vhd) file.

### **Testbench Explanation**
The **disp_ctrl_tb.vhd** testbench tests the display by simulating different distances like **1234**, **0**, **9999**, and more. It checks if the digits displayed are correct.

For the full testbench code, refer to the [disp_ctrl_tb.vhd](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/testbenches/tb_disp_ctrl.vhd) file.

### **Waveform Explanation**
The **disp_ctrl** waveform shows `clk`, `distance`, `seg`, and `an`. It displays the correct digits on the 7-segment display, switching every **1 ms**.

![Distance Measurement Waveform](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/Waveform%20Screenshot/distance_screenshot.png)

---

## **RTL Schema Section**

### **RTL Schema 1**
![RTL Schema 1](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/schematics/RTL%20Schema1.png)

### **RTL Schema 2**
![RTL Schema 2](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/schematics/RTL%20Schema%202.png)

### **RTL Schema 3**
![RTL Schema 3](https://github.com/Mohamedt4r29/Ultrasound-HS-SR04/blob/main/Ultrasonic-Distance-Measurement/schematics/RTL%20Schema%203.png)

---

## **Video Section**
Here is a video showcasing the results of the **Ultrasonic Distance Measurement Project**:

[Video Results](#) *(Link to be added later)*

---
