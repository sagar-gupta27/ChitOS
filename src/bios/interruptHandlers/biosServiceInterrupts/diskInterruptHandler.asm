global disk_interrupt_handler:
    ;check dl for drive number and call the appropriate function
    ;dl = 0x00 - 0x7F for floppy drives
    ;dl = 0x80 - 0xFF for hard drives

; 00h - 7Fh	Floppy drives (Physical / Emulated)
; 80h - 8Fh	Hard disks (HDD, SSD)
; 90h - 9Fh	USB Mass Storage / Removable
; A0h - AFh	SD cards / Embedded Flash storage
; B0h - BFh	RAID, Advanced storage, or vendor
; C0h - CFh	ATAPI / CD-ROM
; D0h - DFh	Tape Drives (Yes! Tape / QIC)
; E0h - EFh	Network Boot Devices (PXE, RPL)
; F0h - FFh	Vendor specific / virtual devices

extern floppy_drive
extern hard_drive
extern usb_mass_storage
extern sd_card
extern raid
extern tape_drive
extern network_boot
extern vendor_specific
extern unknown_device
    
    cmp dl, 0x7F
    jbe floppy_drive   ; 0x00 - 0x7F: Floppy drives
    
    cmp dl, 0x8F
    jbe hard_drive ; 0x80 - 0x8F: Hard drives
    
    cmp dl, 0x9F
    jbe usb_mass_storage ; 0x90 - 0x9F: USB Mass Storage
    
    cmp dl, 0xAF
    jbe sd_card  ; 0xA0 - 0xAF: SD cards
    
    cmp dl, 0xBF
    jbe raid     ; 0xB0 - 0xBF: RAID
    
    cmp dl, 0xDF
    jbe tape_drive ; 0xD0 - 0xDF: Tape drives
    
    cmp dl, 0xEF
    jbe network_boot ; 0xE0 - 0xEF: Network boot devices
    
    cmp dl, 0xFF
    
    jbe vendor_specific ; 0xF0 - 0xFF: Vendor specific
    
    jmp unknown_device ; Unknown device


    
