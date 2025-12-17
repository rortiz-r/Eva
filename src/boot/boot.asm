org 0x7c00
bit 16


start:
    mov si, message
    call print
    jmp $


print:
    