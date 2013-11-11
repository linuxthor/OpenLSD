OpenLSD
=======

Assembly "Hello World" that runs on both Linux and OpenBSD.

Assemble this to make a binary that prints "Linux" on 64 Bit Linux and
"OpenBSD" on 64 Bit OpenBSD. As the syscalls are numbered differently
a simple test is used to determine which OS this is; Syscall 6 (sys_close
on OpenBSD and sys_lstat on Linux) is called with the first argument being
a pointer to the string /proc/self/stat, on Linux we get a return code of
0 as we're calling sys_lstat and the file exists but on OpenBSD this is
sys_close with an invalid FD so we get a -1 error, a comparison of the return
code is used to jump to either OpenBSD or Linux code.

There is probably a better way to do this (and indeed Google tells me an actual
Linux emulation layer in OpenBSD!) but I was drunk and bored..

Assemble with:

nasm -f elf64 -o openlsd.o openlsd.asm
ld -o openlsd openlsd.o

$ file ./openlsd
./openlsd: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically
linked, for OpenBSD, not stripped
 
On Linux:

$ strace ./openlsd
execve("./openlsd", ["./openlsd"], [/* 35 vars */]) = 0
lstat("/proc/self/stat", {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
write(1, "Linux\n", 6Linux
)                  = 6
_exit(42)                               = ?

On OpenBSD:

$ kdump
  5762 ktrace   EMUL  "native"
  5762 ktrace   RET   ktrace 0
  5762 ktrace   CALL  execve(0x7f7ffffe8ab7,0x7f7ffffe89c0,0x7f7ffffe89d0)
  5762 ktrace   NAMI  "/tmp/openlsd"
  5762 openlsd  EMUL  "native"
  5762 openlsd  RET   execve 0
  5762 openlsd  CALL  close(0x600178)
  5762 openlsd  RET   close -1 errno 9 Bad file descriptor
  5762 openlsd  CALL  write(0x1,0x600188,0x8)
  5762 openlsd  GIO   fd 1 wrote 8 bytes
       "OpenBSD
       "
  5762 openlsd  RET   write 8
  5762 openlsd  CALL  exit(0x45)

 
