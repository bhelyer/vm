const hello = "Hello, world."
ld r0, 0x00
ld r1, hello
ld r2, hello.length
ld r3, 0x01
int 0x00
hlt