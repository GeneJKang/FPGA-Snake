### FPGA-Snake
FPGA Snake project for IIT's IGDA Game Jam for the prompt "Patterns".

The project uses a Basys 3 Artix-7 FPGA board from Diligent and it runs a arcade snake game on a VGA monitor at 720p 60 Hz.

## Features
The Snake game is entirely built in SystemVerilog, outputting 1280x720 at 60 Hz VGA. This has game logic, random food placement, rendering, and scoring all in digital logic.

The VGA renderer utilizes a system similar to the NES's PPU which is what I took inspiration from and as a consequence the project uses a real-time hardware renderer with a VGA display controller.

The randomizer uses a 16 bit LFSR so it is technically pseudo random.

The inputs uses a queue system, button synchronizer, and press detection in order to keep a consistent and smooth input for the player. The queue system was especially important as test players noticed the delay when they would coincidentally press 2 inputs within the same tick.

The rest of the project is snake game logic and art display.

## Issues
Due to the nature of the game jam the project was rushed. The big issue the code has is that the WNS on the synthesis on Vivado returns -0.791 ns.

On the game one click period is 13.47 ns and with 3180 Flip Flops being delayed at -0.791 ns the TNS returns -697 ns which is around 0.22 ns on average for each of the 3180 endpoints. This doesn't actually effect the game and was tested during the judging phase of the game jam.

I believe one way to fix this issue is the refactor Snake_Logic.sv so that it can do pipelining. By splitting the calculations from 1 clock cycle to 3 clock cycles each piece will easily fit within 13.47 ns while keeping the clock frequency the same. Of course, this means the game will run slower but with TICK_FRAMES being 24 I believe there is room to spare to keep the speed the same while being able to handle more calculations.

## Notes
For those who were at the game jam: I had a lot of fun and I look forward to meeting you all again!

I will most likely come back to this project, or at least take inspiration of the display system to create my own graphics driver and GPU in the future.

## itch.io page
[itch.io page](https://gene217.itch.io/fpga-snake)

## Pictures
<img width="459" height="293" alt="ezgif-cropped" src="https://github.com/user-attachments/assets/a6ae0802-5881-4ea3-a648-8a2477f781db" />
<img width="560" height="365" alt="Screenshot 2026-10-24 161800" src="https://github.com/user-attachments/assets/05bdfb66-3d82-4803-86ca-ecd3774b5965" />
<img width="768" height="440" alt="Screenshot 2026-10-24 161919" src="https://github.com/user-attachments/assets/3cc6fac4-fc8f-4f14-ba73-e950378d4744" />
<img width="534" height="356" alt="Screenshot 2026-10-24 161940" src="https://github.com/user-attachments/assets/75d7fbc7-32b7-476f-9798-6cab629403ba" />

