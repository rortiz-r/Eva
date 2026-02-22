org 0x7c00
bits 16

; This will give us the offsets of 0x8 and 0x10
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start
    nop

times 33 db 0 ; Create 33 bytes after the short jump.

start:
    jmp 0: step2


step2:
    cli
    mov ax, 0x00
    mov ds, ax
    mov es, ax  
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enabling interrupts


.load_proteced:
    cli
    lgdt[gdt_descriptor] ; This load our gdt_descriptor load the size and load the offset and the start of the gdt
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32

gdt_start:


gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
gdt_code:
    dw 0xffff; Segment limit first 0-15 bits
    dw 0; Base first 0-15 bits
    db 0; Base 16-23 bits
    db 0x9a ; Access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0
; offset 0x10

gdt_data:   ; DS, SS, ES, FS, GS
    dw 0xffff; Segment limit first 0-15 bits
    dw 0; Base first 0-15 bits
    db 0; Base 16-23 bits
    db 0x92 ; Access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

[BITS 32]
load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000
    call read_ata

    

times 510-($-$$) db 0
dw 0xAA55


