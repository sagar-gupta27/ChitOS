bits   16
org    0x0000

global setup_ivt

setup_ivt:

    ; Setup INT 00h - Divide Error
    mov ax,            Offset divide_error
    mov word [0x00*4], ax

    mov ax,              seg divide_error
    mov word [0x00*4+2], ax

    ; Setup INT 01h - Debug Exception
    mov ax,            Offset debug_exception
    mov word [0x01*4], ax

    mov ax,              seg debug_exception
    mov word [0x01*4+2], ax

    ; Setup INT 02h - Non-Maskable Interrupt
    mov ax,            Offset nmi_handler
    mov word [0x02*4], ax

    mov ax,              seg nmi_handler
    mov word [0x02*4+2], ax

    ; Setup INT 03h - Breakpoint
    mov ax,            Offset breakpoint_handler
    mov word [0x03*4], ax

    mov ax,              seg breakpoint_handler
    mov word [0x03*4+2], ax

    ; Setup INT 04h - Overflow
    mov ax,            Offset overflow_handler
    mov word [0x04*4], ax

    mov ax,              seg overflow_handler
    mov word [0x04*4+2], ax

    ; Setup INT 05h - Bound Range Exceeded
    mov ax,            Offset bound_range_exceeded
    mov word [0x05*4], ax

    mov ax,              seg bound_range_exceeded
    mov word [0x05*4+2], ax

    ; Setup INT 06h - Invalid Opcode
    mov ax,            Offset invalid_opcode
    mov word [0x06*4], ax

    mov ax,              seg invalid_opcode
    mov word [0x06*4+2], ax

    ; Setup INT 07h - Device Not Available
    mov ax,            Offset device_not_available
    mov word [0x07*4], ax

    mov ax,              seg device_not_available
    mov word [0x07*4+2], ax

    ; Setup INT 08h - Double Fault
    mov ax,            Offset double_fault
    mov word [0x08*4], ax

    mov ax,              seg double_fault
    mov word [0x08*4+2], ax

    ; Setup INT 09h - Coprocessor Segment Overrun
    mov ax,            Offset coprocessor_segment_overrun
    mov word [0x09*4], ax

    mov ax,              seg coprocessor_segment_overrun
    mov word [0x09*4+2], ax

    ; Setup INT 0Ah - Invalid TSS
    mov ax,            Offset invalid_tss
    mov word [0x0A*4], ax

    mov ax,              seg invalid_tss
    mov word [0x0A*4+2], ax

    ; Setup INT 0Bh - Segment Not Present
    mov ax,            Offset segment_not_present
    mov word [0x0B*4], ax

    mov ax,              seg segment_not_present
    mov word [0x0B*4+2], ax

    ; Setup INT 0Ch - Stack-Segment Fault
    mov ax,            Offset stack_segment_fault
    mov word [0x0C*4], ax

    mov ax,              seg stack_segment_fault
    mov word [0x0C*4+2], ax

    ; Setup INT 0Dh - General Protection Fault
    mov ax,            Offset general_protection_fault
    mov word [0x0D*4], ax

    mov ax,              seg general_protection_fault
    mov word [0x0D*4+2], ax

    ; Setup INT 0Eh - Page Fault
    mov ax,            Offset page_fault
    mov word [0x0E*4], ax

    mov ax,              seg page_fault
    mov word [0x0E*4+2], ax

    ; Setup INT 0Fh - Reserved
    mov ax,            Offset reserved_handler
    mov word [0x0F*4], ax

    mov ax,              seg reserved_handler
    mov word [0x0F*4+2], ax


    ; Setup INT 10h - Video Services
    mov ax,              Offset video_services
    mov word [0x10*4],   ax
    mov ax,              seg video_services
    mov word [0x10*4+2], ax

    ; Setup INT 13h - Disk Services
    mov ax,              Offset disk_routine
    mov word [0x13*4],   ax
    mov ax,              seg disk_routine
    mov word [0x13*4+2], ax

    ; Setup INT 14h - Serial Port Services
    mov ax,              Offset serial_port
    mov word [0x14*4],   ax
    mov ax,              seg serial_port
    mov word [0x14*4+2], ax
    
    ; Setup INT 15h - Miscellaneous Services
    mov ax,              Offset misc_service
    mov word [0x15*4],   ax
    mov ax,              seg misc_service
    mov word [0x15*4+2], ax
    
    ; Setup INT 16h - Keyboard Services
    mov ax,              Offset keyboard_service
    mov word [0x16*4],   ax
    mov ax,              seg keyboard_service
    mov word [0x16*4+2], ax
    
    ; Setup INT 17h - Printer Services
    mov ax,              Offset printer_service
    mov word [0x17*4],   ax
    mov ax,              seg printer_service
    mov word [0x17*4+2], ax
    
    ; Setup INT 18h - Boot Failure
    mov ax,              Offset boot_failure
    mov word [0x18*4],   ax
    mov ax,              seg boot_failure
    mov word [0x18*4+2], ax
    
    ; Setup INT 19h - Bootloader Services
    mov ax,              Offset bootloader_service
    mov word [0x19*4],   ax
    mov ax,              seg bootloader_service
    mov word [0x19*4+2], ax
   
    ; Setup remaining interrupts with a default handler
    mov ax,              Offset default_handler
    mov bx,              0xF000
    mov cx,              256
    xor dx,              dx                        ; Start from INT 00h
setup_loop:
    cmp dx,            0x10
    je  skip_setup          ; Skip already set INT 10h
    cmp dx,            0x13
    je  skip_setup          ; Skip already set INT 13h
    cmp dx,            0x14
    je  skip_setup          ; Skip already set INT 14h
    cmp dx,            0x15
    je  skip_setup          ; Skip already set INT 15h
    cmp dx,            0x16
    je  skip_setup          ; Skip already set INT 16h
    cmp dx,            0x17
    je  skip_setup          ; Skip already set INT 17h
    cmp dx,            0x18
    je  skip_setup          ; Skip already set INT 18h
    cmp dx,            0x19
    je  skip_setup          ; Skip already set INT 19h
    ; Set default handler for unused interrupts
    mov word [dx*4],   ax
    mov word [dx*4+2], bx
skip_setup:
    inc  dx
    loop setup_loop
    ret
; Default handler for unused interrupts
default_handler:
    cli                 ; Disable interrupts
    hlt                 ; Halt the CPU
    jmp default_handler ; Infinite loop
