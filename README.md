# 🕹 Sport Clock – 4 Nút Bấm (AT89C51/AT89C52)

## 📌 Introduction:
A sport clock based on AT89C51, displaying time on 4-digit 7-segment LEDs with a precision of 0.01 seconds (00.00s → 99.99s). The system supports 4 control modes implemented through external interrupts.

## Schematic:
![schematic.bmp](asset\schematic.BMP)

## 🎛 Funtion:
- **Button A (INT0)**: Pause / Resume.  
- **Button B (INT1)**: Reset timer to `00.00`.  
- **Button C (P1.4 + INT0)**: Increase timer by **1s**.  
- **Button D (P1.5 + INT1)**: Decrease timer by **1s**.  

## ⚡ Working Principle:
- **Timer 1**: create a 10ms (0.01s) time counting cycle.
- **Timer 0**: create a delay for the LED display scan.
- **External INT0, INT1**: handle button events (Pause/Resume, Reset, Tăng, Giảm).  
- **R6, R7 registers**: store the decimal part and the integer part of the time.

## 🔗 Proteus Simulation:

![Simulation.webm](https://github.com/user-attachments/assets/0a006352-5118-496b-ae9b-591133156ec2)

[Google Drive](https://drive.google.com/file/d/1LzE1PslYNJz4D2bf1CjuAcTLHaWI4JPU/view?usp=sharing)  

