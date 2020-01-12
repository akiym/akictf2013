all:
	cc65 -t nes main.c
	ca65 -t nes main.s
	ld65 -t nes main.o nes.lib atmos.lib -o crackme.nes

clean:
	rm main.s main.o crackme.nes
