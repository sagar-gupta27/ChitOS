; Register	Purpose
; AH	Function number (command).
; AL	Number of sectors to read/write.
; CH	Cylinder number.
; CL	Sector number.
; DH	Head number.
; DL	Drive number (0x00 to 0x7F = floppy).
; ES:BX	Data buffer pointer in RAM.

global floppy_drive
floppy_drive:
    ; Save registers
   push ax
   push bx
   push cx
   push dx
   push es
   push di


   cmp ah, 0x00
   je  .floppy_reset
   
   cmp ah, 0x01
   je  .floppy_read
   
   cmp ah, 0x02
   je  .floppy_write
   
   cmp ah, 0x03
   je  .floppy_format
   
   cmp ah, 0x04
   je  .floppy_verify
   
   cmp ah, 0x05
   je  .floppy_format_track
   
   cmp ah, 0x08
   je  .floppy_read_dsk_info


   cmp ah, 0x0C
   je  .floppy_seek

   
   
.floppy_reset:
   ;Reset FDC controller
   ;Floppy controller I/O ports
   ;0x3F2 - Digital Output Register
   ;0x3F4 - Main Status Register
   ;0x3F5 - Data Port

   mov dx, 0x3F2 ;DOS
   mov al, 0x00  ;Reset FDC
   out dx, al

   jmp $+2 ;small delay
    
   mov al, 0x01 ;Enable Controller
   out dx, al

   .floppy_read:
   ;Read sectors from floppy disk
   ;Function 0x01
   ;AH = 0x01
   ;AL = Number of sectors to read
   ;CH = Cylinder number
   ;CL = Sector number
   ;DH = Head number
   ;DL = Drive number (0x00 to 0x7F = floppy)
   ;ES:BX = Data buffer pointer in RAM
   ;Return: CF = 0 if successful, CF = 1 if error

   
  
    in al, 0x3F2       ; Read the DOR value
    and al, 0xF0       ; Mask out previous drive select and motor control bits
    or al, dl          ; Set the appropriate drive number (DL)
    or al, 0x0C        ; Enable the controller and motor
    out 0x3F2, al      ; Write the value back to the DOR

    ; Step 2: Send the read command to the FDC
    ; Setup the read sector command for the FDC.
    ; The parameters we need to send to the FDC:
    ; - Command (0x02 for read)
    ; - Cylinder (CH)
    ; - Sector (CL)
    ; - Head (DH)
    ; - Number of sectors to read (AL, here it's 1)

    ; First send the command byte to the FDC (0x06 - Read sector command)
    mov al, 0x06        ; FDC read sector command
    out 0x3F5, al       ; Send command to FDC

    ; Send the parameters
    mov al, ch          ; Cylinder (CH)
    out 0x3F5, al       ; Send high byte of cylinder
  
    mov al, cl          ; Sector (CL)
    out 0x3F5, al       ; Send sector number
  
    mov al, dh          ; Head (DH)
    out 0x3F5, al       ; Send head number
  
    mov al, al          ; Number of sectors (AL)
    out 0x3F5, al       ; Send number of sectors to read

    ; Step 3: Wait for the FDC to complete the operation (IRQ6)
    ; This is a blocking call, so we will wait until the FDC is ready
    ; We will poll the status register until the FDC is ready
    ; The status register is at port 0x3F4
    ; The status register bits we are interested in:
    ; - Bit 7: Data Request (DRQ)
    ; - Bit 6: Not Ready (NRDY)
    ; - Bit 5: Write Protect (WP)
    ; - Bit 4: Index (INDEX)
    ; - Bit 3: Track 0 (T0)
    ; - Bit 2: Lost Data (LD)
    ; - Bit 1: Seek Complete (SC)
    ; - Bit 0: Data Request (DRQ)
    ; We will wait until DRQ is set and NRDY is clear
    ; This means the FDC is ready to send data
    ; We will also check for errors (NRDY, WP, INDEX, T0, LD, SC)
    ; If any of these bits are set, we will return an error
    ; If DRQ is set, we will read the data from the FDC
    ; The data is read from port 0x3F7
    ; The data is read into the buffer pointed to by ES:BX
    ; The number of bytes to read is AL (number of sectors * 512 bytes)
    ; The FDC will send 512 bytes for each sector
    ; We will read the data into the buffer pointed to by ES:BX
    ; We will read the data in a loop until we have read all the bytes
    ; We will use a counter to keep track of the number of bytes read
    ; The counter will be decremented each time we read a byte
    ; When the counter reaches zero, we will return
    