const hello = "Hello, world."
load r0, 0x00
load r1, hello
load r2, hello.length
load r3, 0x01
interrupt 0x00
halt