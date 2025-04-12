;Interrupt handlers for BIOS interrupts
bits 16      ;Working in 16 real mode 

 ;int10 Handler -->BIOS Interrupt handler for videos services
int10_handler:
 pusha ; always save the current state first
 mov ah, [cs:bx] ; get function number
 cmp ah, 0x0E    ; check if its teletype output
 jne int_10_exit ;

 mov al, [cs:bx+1]         ; char to print
 mov di, [cs:cursor_pos]   ; set the destination of charactor to current cursor position
 mov es, 0xB800            ;Video segment for color text
 mov [es:di],al            ;Write ASCII Charactor ; as soon as the h/w adress is written character is displayed
 mov byte [es:di +1],0x07  ;setting the attribute
 add word [cs:cursor_pos], 2; Move cursor to right
  

 ; Basic handling for end of screen (80x25 text mode = 4000 bytes).
 cmp word [cs:cursor_pos], 4000
 jb int_10_exit
 mov word [cs:cursor_pos], 0   ; Reset cursor to top if screen full.

int_10_exit:
 popa ;Restore the state of CPU
 iret ;Return from the interrupt handler

cursor_pos: dw 0  ; Cursor offset from start of video memory.
 
;int11 Handler --> Equipment List (detect system config)
int11_handler:

;int12 Handler
int12_handler:

;int13 Handler --> Disk I/O , read write sectors from hard disk / floppy 
; ;When you call INT 0x13, you set up:

; AH = Function Number
; 
; Other registers = Function-specific parameters
; 
; After the interrupt:
; 
; AH = Return Status Code (if CF=1)
; 
; CF (Carry Flag) = Set if error, clear if success. */

int13_handler:
 pusha
 mov ah, [cs:bx] ;Get Function code

 cmp ah, 0x00
 je reset_disk_sys

 cmp ah, 0x01
 je get_last_op_status
 
 cmp ah, 0x02
 je read_sectors

 cmp ah, 0x03
 je write_sectors

 cmp ah, 0x04
 je verify_sectors
 
 cmp ah , 0x05
 je format_track

 cmp ah, 0x08
 je get_drive_param

 cmp ah , 0x15
 je get_disk_type

 cmp ah, 0x41
 je extended_inst_check

 cmp ah, 0x42 
 je extended_read

 cmp ah, 0x43
 je extended_write

 
;int14 Handler
;int15 Handler
;int16 Handler
;int17 Handler
;int18 Handler
;int19 Handler
;int1A Handler
 
 ;CPU TEST
 
