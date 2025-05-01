cdrom_drive:
cmp ah, 0x00
je cd_reset_drive

cmp ah, 0x01
je cd_get_status

cmp ah, 0x02
je cd_read_sector

cmp ah, 0x03
je cd_write_sector

cmp ah, 0x08
je cd_get_drive_param

cmp ah, 0x42
je cd_ext_read

cmp ah, 0x43
je cd_ext_write

cmp ah, 0x44
je cd_verify_ext

cmp ah, 0x46
je cd_get_ext_drive_param

cmp ah, 0x48
je cd_get_drive_geo

stc
mov ah, 0x01
ret