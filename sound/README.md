## sound

web audio api seems supported now to try playing the original signal data

I asked claude to make demo.html to test the sounds and songs from the following info:

- ../doc/disasm/scott.asm (Ms Pac-Man documented disassembly)
- ./vecoven-article (Frederic Vecoven reverse-engineered the sound parts of the above document)

The sounds seem to be working well in the demo. Some problems:

1. not sure how to get the original Pac-Man sound effects.
2. not sure why the Act 2 song from Ms. Pac-Man is missing.

My plan:

1. go through demo.html and understand what was put together
2. find a way to manually move the data for the songs and effects into the game in a way that can be read
3. move the sound engine to its own file src/sound.js
