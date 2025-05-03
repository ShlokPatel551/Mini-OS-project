;; bootloader/boot.asm - 512-byte bootloader that loads the kernel

... [bootloader and kernel code unchanged for brevity] ...


/* kernel/keyboard.c - Add keyboard input using BIOS interrupt */

#include <stdint.h>
#define VGA ((volatile char*)0xB8000)
#define WHITE_ON_BLACK 0x0F

void keyboard_input() {
    char c;
    __asm__ __volatile__ (
        "mov $0x00, %%ah\n"
        "int $0x16\n"
        "mov %%al, %0\n"
        : "=r"(c)
        :
        : "ah", "al"
    );

    // Show the key on screen (after "Welcome" text)
    VGA[164] = c;
    VGA[165] = WHITE_ON_BLACK;
}


/* kernel/kernel.c - updated to include keyboard input */

#include <stdint.h>

#define VGA_BUFFER ((volatile char*)0xB8000)
#define WHITE_ON_BLACK 0x0F

extern void load_task1();
extern void load_task2();
extern void keyboard_input();

void print(const char* str) {
    volatile char* vga = VGA_BUFFER;
    while (*str) {
        *vga++ = *str++;
        *vga++ = WHITE_ON_BLACK;
    }
}

void kernel_main() {
    print("\nWelcome to MiniOS!\n");

    while (1) {
        load_task1();
        load_task2();
        keyboard_input();
    }
}


/* Add keyboard.c to Makefile */

# Makefile - build and run MiniOS (updated)

NASM=nasm
CC=gcc
LD=ld
CFLAGS=-ffreestanding -m32 -nostdlib
LDFLAGS=-T linker.ld

all: os-image

bootloader.bin:
	$(NASM) -f bin bootloader/boot.asm -o bootloader.bin

kernel.o: kernel/kernel.c kernel/scheduler.c kernel/keyboard.c
	$(CC) $(CFLAGS) -c kernel/kernel.c -o kernel.o
	$(CC) $(CFLAGS) -c kernel/scheduler.c -o scheduler.o
	$(CC) $(CFLAGS) -c kernel/keyboard.c -o keyboard.o

kernel.bin: kernel.o scheduler.o keyboard.o
	$(LD) $(LDFLAGS) -o kernel.elf kernel.o scheduler.o keyboard.o
	objcopy -O binary kernel.elf kernel.bin

os-image: bootloader.bin kernel.bin
	cat bootloader.bin kernel.bin > os-image

run: os-image
	qemu-system-i386 -drive format=raw,file=os-image

clean:
	rm -f *.o *.bin *.elf os-image


## 🧪 Updated README Feature

## ✨ New Feature: Keyboard Input!
When you press a key while MiniOS is running, it will show up on the screen after the welcome message.

We added:
- `kernel/keyboard.c` for reading keystrokes using BIOS interrupt 16h
- Updated kernel loop to call `keyboard_input()`
