# 🔁 FPGA Project: Rotary Encoder Angle Display, RS232 Communication, and Digital Clock

## 📘 Project Overview

This project implements a multi-functional embedded system using the **Basys2 FPGA development board**, focusing on:

1. **Reading angular position from a rotary encoder** and displaying it on a **seven-segment display**.
2. **Serial communication (RS232)** between FPGA and PC via a **USB-to-TTL module**.
3. A **real-time digital clock** shown on the same seven-segment display.

This project combines real-time sensor interfacing, display multiplexing, and serial communication—all in Verilog, designed for beginner-to-intermediate FPGA learners.

---

## 🧰 Hardware Used

| Component                  | Description/Details                                   |
|---------------------------|--------------------------------------------------------|
| 🧠 FPGA Board             | Digilent Basys2 (Spartan-3E)                          |
| 🎚️ Rotary Encoder         | Incremental quadrature encoder with A & B channels    |
| 🖥️ Display                | Onboard 4-digit seven-segment display on Basys2 board |
| 🔌 Serial Converter       | USB to TTL (CP2102 / CH340) module                    |
| ⏲️ Clock Source           | 50 MHz onboard oscillator                             |
| 🔘 Push Buttons & Switches | Onboard (for Reset/Mode selection)                   |

---

## 🧠 Functional Description

### 1. 🎚️ Rotary Encoder Angle Measurement
- The rotary encoder's A and B outputs are connected to digital I/O pins on the FPGA.
- The system detects **rising/falling edges** and **phase differences** to determine rotation direction and steps.
- Angle is calculated as:
- The angle (0° to 359°) is displayed on the seven-segment display.

---

### 2. 🔄 RS232 Communication via USB-TTL
- Implements UART TX module on FPGA for serial communication with a PC.
- RS232 logic level is bypassed—**TTL level signals** are directly transmitted using USB to TTL (e.g., CP2102).
- Baud rate: **9600 bps**
- Transmitted data format:

Use a serial terminal (e.g., PuTTY, TeraTerm, or Python + PySerial) on the PC side to read the data.

---

### 3. ⏰ Digital Clock
- A real-time digital clock is implemented using counters based on the 50 MHz clock.
- Time updates every second (tracked using clock divider logic).
- Clock format displayed: `HH:MM`
- Clock values are updated and transmitted via UART as well.

---

## 📂 Project Structure


---

## ⚙️ How to Set Up

### 🔌 Wiring
- **Encoder A** → FPGA Digital Input (e.g., JA connector pin)
- **Encoder B** → FPGA Digital Input
- **USB-TTL TX** → FPGA RX (if using RX module)
- **FPGA TX** → USB-TTL RX (connect this for PC receive)
- **GND** → Common ground between USB-TTL and FPGA

### ⚒️ Synthesis & Programming
1. Open Xilinx ISE WebPACK and create a new project.
2. Add the Verilog source files and UCF constraints.
3. Synthesize, implement, and generate bitstream.
4. Upload to Basys2 using Adept or iMPACT.

### Photos of the projects 
![Encoder Image](/topview.jpg)
![Digital Clock](/digital clock.png)
![Encoder Working video](/digital clock.mp4)
---



