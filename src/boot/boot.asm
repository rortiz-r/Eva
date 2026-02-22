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
    jmp CODE_SEG:0x0100000


read_ata:
    mov ebx, eax ; Backup the LBA
    shr eax, 24 ; 32-24 shift eax register 24 bits eax will contain highest 8 bits of the lba
    or eax, 0xE0
    mov dx, 0x1F6
    out dx, al

    ; Send the total sectors to the hard disk controller
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al

    mov eax, ebx
    mov dx, 0x1F3
    out dx, al

    ; Send more bits of the LBA
    mov dx, 0x1F4
    mov eax, ebx
    shr eax, 8
    out dx, al
    
    ; Send upper 16 bits of the LBA

    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx, al


    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

.next_sector:
    push ecx

.try_again:
    mov dx, 0x1f7
    in al, dx
    test al, 8
    jz .try_again


    mov ecx, 256
    mov dx, 0x1f0
    rep insw
    pop ecx
    loop .next_sector

    ret
    

times 510-($-$$) db 0
dw 0xAA55


