hdd_drive:
cmp ah, 0x00
je hdd_reset_drive

cmp ah, 0x01
je hdd_last_op_status

cmp ah, 0x02
je hdd_read_sector

cmp ah, 0x03
je hdd_write_sector
