# Mini-OS-project
I've added the bootloader code for your Mini OS project—this is the boot.asm file that fits in the 512-byte boot sector and loads a kernel from disk.

;; bootloader/boot.asm - 512-byte bootloader that loads the kernel

... [bootloader and kernel code unchanged for brevity] ...

# Makefile - build and run MiniOS

... [Makefile content unchanged for brevity] ...


# README.md - Simple explanation of MiniOS project

## 🧠 What is MiniOS?
MiniOS is a very basic operating system that shows how a bootloader and a simple kernel work. It runs on real or virtual hardware using QEMU.

## 📁 What's inside?
- `bootloader/boot.asm`: Assembly code that starts the computer and loads the kernel.
- `kernel/kernel.c`: Simple C kernel that prints a message and switches between two tasks.
- `kernel/scheduler.c`: Contains two fake "tasks" that write characters to screen.
- `linker.ld`: Tells the linker where to place code in memory.
- `Makefile`: Automates the build and run process.

## 🛠️ How to build it?
1. Make sure you have these tools installed:
   - `nasm`
   - `gcc` (32-bit)
   - `ld`
   - `qemu`

2. Run this in terminal:
```bash
make
```

3. To run it in a virtual machine:
```bash
make run
```

## 🧪 What does it do?
- Shows "Welcome to MiniOS!" on the screen.
- Then switches between two tasks that display numbers `1` and `2`.

## 🔄 Clean up
```bash
make clean
```
This will delete all build files.

## ✅ Why is it cool?
- It helps you learn how real OSes work from the ground up.
- Shows how CPUs start, load memory, and run code.

Feel free to improve it by adding keyboard input, timer interrupts, or a real task scheduler!
