# Masters
Projects done during Master study

00: Free ARM compatible softcores on Artix 7 FPGA

ARM processor is a 32-bit Reduced Instruction Set Computer (RISC) processor, Instruction Set
Architecture (ISA). The ARM architecture has the best MIPS to Watts ratio as well as best
MIPS to euros ratio in the industry; the smallest CPU size; all the necessary computing capability
couples with low power consumption of which a highly flexible and customizable set of processors
are available with options to choose from, all at a low cost.

In fact, the small size, low cost, and low power usage leads to one of the most common uses for
an ARM processor today, embedded applications. Embedded environments like cell phones or
Personal Digital Assistants (PDAs) require those benefits that this architecture provides.

In this project ARM softcore - STORM is emulated on an Artix-7 FPGA. We are using the
FPGA Board TE0711 from Trenz Electronic. The existing core is checked using an external
module of memory and IO controller. In the project, the author extends the core by
adding the memory and IO controller to the main core. The LCD controller design is also
added to the core to display the output in the LCD display from Electronic
Assembly - DOGM204A.
The data from the IO controller is extracted from STORM core which is running on the FPGA.
The extracted data is displayed on LCD display connected to the FPGA on a Debug board.
The Debug has the push button control switches Start, Stop, Step and Reset to control the
execution of program running on the STORM core.
Programming Language: VHDL
Board: Artix 7
IDE: Xilinx Vivado

01: Design and Implementation of Stopwatch on Spartan 3e FPGA

The Aim of this project is to design the functionality of the digital stopwatch and switching
between the different operational states which depends on the user input given using the pushbuttons.
Programming Language: VHDL
Board: Spartan 3e
IDE: Xilinx ISE

02: Design of Analog to Digital Converter

The Aim of this project is to design the analog to digital converter.
Programming Language: VHDL
IDE: ModelSim