#include "stdint.h"
#include "stdio.h"

/*
cdecl calling convention
- Arguments are passed on the stack from right to left
- The caller cleans the stack
- The return value is passed in EAX
- The caller is responsible for preserving the registers EAX, ECX, and EDX
- Intergers are returned in EAX
- Floating point values are returned in ST0
- name mangling , so the function name is prefixed with an underscore
*/
void  _cdecl cstart_(int boot_drive){ // compiler will add _ int the function name so don't add it manually
    puts("Hello world from C!\r\n");
    printf("Formatted %% %c %s %ls\r\n", 'a', "string", "far_str");
    printf("Formatted %d %i %x %p %o %hd %hi %hhu %hhd\r\n", 1234, -5678, 0xdead, 0xbeef, 012345, (short)27, (short)-42, (unsigned char)20, (signed char)-10);
    printf("Formatted %ld %lx %lld %llx\r\n", -100000000l, 0xdeadbeeful, 10200300400ll, 0xdeadbeeffeebdaedull);
    printf("Formatted %llx",0xaeffbcdefffffff);
    for (;;);
    for (;;);
}