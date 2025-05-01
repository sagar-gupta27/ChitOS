bits   16

global divide_error                   ; 0x00
global debug_exception                ; 0x01
global nmi_handler                    ; 0x02
global breakpoint_handler             ; 0x03
global overflow_handler               ; 0x04
global bound_range_exceeded           ; 0x05
global invalid_opcode                 ; 0x06
global device_not_available           ; 0x07
global double_fault                   ; 0x08
global coprocessor_segment_overrun    ; 0x09
global invalid_tss                    ; 0x0A
global segment_not_present            ; 0x0B
global stack_segment_fault            ; 0x0C
global general_protection_fault       ; 0x0D
global page_fault                     ; 0x0E
global coprocessor_error              ; 0x0F
global alignment_check_exception      ; 0x10
global machine_check_exception        ; 0x11
global simd_floating_point_exception  ; 0x12
global virtualization_exception       ; 0x13
global control_protection_exception   ; 0x14
global hypervisor_injection_exception ; 0x15
global vmm_communication_exception    ; not fixed
global security_exception             ; not fixed
global x87_floating_point_exception   ; 0x1E


divide_error:
debug_exception:
nmi_handler:
breakpoint_handler:
overflow_handler:
bound_range_exceeded:
invalid_opcode:
device_not_available:
double_fault:
coprocessor_segment_overrun:
invalid_tss:
segment_not_present:
stack_segment_fault:
general_protection_fault:
page_fault:
coprocessor_error:
alignment_check_exception:
machine_check_exception:
simd_floating_point_exception:
virtualization_exception:
control_protection_exception:
hypervisor_injection_exception:
vmm_communication_exception:
security_exception:
x87_floating_point_exception: