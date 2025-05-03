;; bootloader/boot.asm - 512-byte bootloader that loads the kernel

BITS 16
ORG 0x7C00

start:
    cli                     ; disable interrupts
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov si, msg
    call print_string

    ; load kernel (assume it's the next 15 sectors)
    mov ah, 0x02            ; BIOS read sectors function
    mov al, 15              ; number of sectors to read
    mov ch, 0               ; cylinder
    mov cl, 2               ; sector (start at 2, after boot sector)
    mov dh, 0               ; head
    mov dl, 0x80            ; drive number
    mov bx, 0x1000          ; load kernel to 0x1000
    int 0x13                ; BIOS disk interrupt
    jc disk_error           ; jump if error

    jmp 0x0000:0x1000       ; jump to loaded kernel

print_string:
    mov ah, 0x0E
.next:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .next
.done:
    ret

disk_error:
    mov si, err_msg
    call print_string
    jmp $

msg db 'Booting MiniOS...', 0
err_msg db 'Disk read error!', 0

times 510 - ($ - $$) db 0
DW 0xAA55


/* kernel/kernel.c - minimal kernel with basic scheduler */

#include <stdint.h>

#define VGA_BUFFER ((volatile char*)0xB8000)
#define WHITE_ON_BLACK 0x0F

extern void load_task1();
extern void load_task2();

void print(const char* str) {
    volatile char* vga = VGA_BUFFER;
    while (*str) {
        *vga++ = *str++;
        *vga++ = WHITE_ON_BLACK;
    }
}

void kernel_main() {
    print("\nWelcome to MiniOS!\n");

    // Simulated scheduler loop
    while (1) {
        load_task1();
        load_task2();
    }
}


/* kernel/scheduler.c - simple cooperative scheduler */

__attribute__((naked)) void load_task1() {
    static int i = 0;
    VGA_BUFFER[160] = '1';
    VGA_BUFFER[161] = WHITE_ON_BLACK;
    i++;
}

__attribute__((naked)) void load_task2() {
    static int j = 0;
    VGA_BUFFER[162] = '2';
    VGA_BUFFER[163] = WHITE_ON_BLACK;
    j++;
}


/* linker.ld - Linker script */

ENTRY(kernel_main)

SECTIONS {
    . = 0x1000;
    .text : { *(.text) }
    .data : { *(.data) }
    .bss  : { *(.bss)  }
}


# Makefile - build and run MiniOS

NASM=nasm
CC=gcc
LD=ld
CFLAGS=-ffreestanding -m32 -nostdlib
LDFLAGS=-T linker.ld

all: os-image

bootloader.bin:
	$(NASM) -f bin bootloader/boot.asm -o bootloader.bin

kernel.o: kernel/kernel.c kernel/scheduler.c
	$(CC) $(CFLAGS) -c kernel/kernel.c -o kernel.o
	$(CC) $(CFLAGS) -c kernel/scheduler.c -o scheduler.o

kernel.bin: kernel.o scheduler.o
	$(LD) $(LDFLAGS) -o kernel.elf kernel.o scheduler.o
	objcopy -O binary kernel.elf kernel.bin

os-image: bootloader.bin kernel.bin
	cat bootloader.bin kernel.bin > os-image

run: os-image
	qemu-system-i386 -drive format=raw,file=os-image

clean:
	rm -f *.o *.bin *.elf os-image
