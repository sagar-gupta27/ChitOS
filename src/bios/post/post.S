section .text
    ; Set entry point explicitly
    global _start
    _start:
        cli                       ; Disable interrupts during setup
        cld                       ; Clear Direction Flag (String operations increment)

        ; Setup flat real-mode segments
        xor ax, ax
        mov ds, ax
        mov es, ax
        mov ss, ax

        ; Setup basic stack (at 0x7C00)
        mov sp, 0x7C00            ; Stack pointer (use top of free space under BIOS)

        ; Now the real code begins

        ; Enable A20 Line (Fast method first)
        call enable_a20_fast

        ; Check if CPUID is supported
        call check_cpuid

        ; Hang the system here for now (POST can print stuff after we finish)
        jmp $

; === A20 Enabling Code ===
enable_a20_fast:
    in al, 0x92               ; Read port 92h (System Control Port A)
    or al, 00000010b          ; Set A20 Enable bit (bit 1)
    out 0x92, al              ; Write it back
    call a20_check            ; Verify if A20 really enabled
    jc .failed                ; If failed, fallback to slow method
    ret

.failed:
    ; Fall back to slow 8042 method
    call enable_a20_8042
    ret

enable_a20_8042:
    ; Wait for input buffer to be empty
.wait_ibf_clear:
    in al, 0x64               ; Status Register
    test al, 00000010b        ; Input Buffer Full?
    jnz .wait_ibf_clear       ; Wait if full

    ; Send command to write output port
    mov al, 0xD1
    out 0x64, al

    ; Wait for input buffer to be empty again
.wait_ibf_clear2:
    in al, 0x64
    test al, 00000010b
    jnz .wait_ibf_clear2

    ; Write output port value with A20 set
    mov al, 00000010b
    out 0x60, al

    ; Verify again if A20 is enabled
    call a20_check
    ret

a20_check:
    ; Save registers
    push ax
    push ds
    push es

    ; Setup segment for testing
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    sti

    ; Write different values to address 0x000 and 0x100000 (1MB)
    mov si, 0x0000
    mov di, 0x0000

    mov al, [si]
    mov ah, [es:si+0x100000-0xFFFF0] ; Read memory beyond 1MB (trick for real mode)

    ; Compare
    cmp al, ah
    jne .ok

    ; If equal, A20 is still disabled
    stc                ; Set Carry Flag to indicate failure
    pop es
    pop ds
    pop ax
    ret

.ok:
    clc                ; Clear Carry Flag to indicate success
    pop es
    pop ds
    pop ax
    ret

; === CPU Detection Code ===
check_cpuid:
    ; Check CPUID support
    pushfd
    pop eax
    mov ecx, eax

    xor eax, 0x200000
    push eax
    popfd

    pushfd
    pop eax

    xor eax, ecx
    and eax, 0x200000
    jz .no_cpuid        ; CPUID not supported

    ; CPUID supported
    call get_cpuid_info
    ret

.no_cpuid:
    ; Mark unsupported
    ret

get_cpuid_info:
    ; Get CPU Vendor ID
    xor eax, eax
    cpuid

    ; Save Vendor String (EBX, EDX, ECX order)
    mov [cpu_vendor_id + 0], ebx
    mov [cpu_vendor_id + 4], edx
    mov [cpu_vendor_id + 8], ecx

    ; Get Family, Model, Stepping
    mov eax, 1
    cpuid

    ; Now parse EAX
    mov bl, al           ; Save AL (lowest 8 bits of EAX)

    ; Stepping = bits 0-3
    and bl, 0x0F
    mov [cpu_stepping], bl

    ; Model = bits 4-7
    mov bl, al
    shr bl, 4
    and bl, 0x0F
    mov [cpu_model], bl

    ; Family = bits 8-11
    mov bx, ax
    shr bx, 8
    and bl, 0x0F
    mov [cpu_family], bl

    ret

section .bss
    cpu_vendor_id:    resb 12     ; 12 bytes (Vendor string)
    cpu_family:       resb 1      ; 1 byte
    cpu_model:        resb 1      ; 1 byte
    cpu_stepping:     resb 1      ; 1 byte
