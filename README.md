# STM32 - ASSEMBLY ARM - SIMULATION OF AN AUTOMATIC PARKING LOT

## Made for the college discipline ELTD13A - Microcontroladores e Microprocessadores at the Federal University of Itajubá (UNIFEI)

### Introduction
This project involves the proposition and development of an automated parking system. Using sensors, the system detects the presence of vehicles and manages the availability of parking spaces in real time. The system has two blocks of spaces, A and B, each with four spaces. Users can indicate their preferred block, and the system, based on sensor information and the driver's preference, provides information on space availability and exact location.

### Justification
The implementation of an automated parking system is justified by the need to optimize the use of spaces and facilitate the lives of drivers. The system reduces the time spent searching for spaces, improves vehicle flow, and decreases congestion in urban areas.

### Physical Components
- **Keypad:** Electromechanical device used to select the preferred block (A or B).
- **LCD Display:** 2x16 LCD that displays information about the availability and location of spaces.
- **LEDs:** Light indicators controlled by the microcontroller to signal the driver's preference.
- **Power Supply:** Provides energy for the system, including the STM32F103C8 microcontroller mounted on the Blue Pill board.

### Developed Program
The program was developed in Assembly language for the STM32F103C8 microcontroller. The project code is responsible for managing the parking system operations, including reading the keypad, controlling the LEDs, and displaying information on the LCD.

### Conclusion
This project demonstrates the practical application of an automated parking system, using sensors and a microcontroller to manage and optimize space occupancy. The implementation can be expanded to include more blocks of spaces and additional functionalities.
