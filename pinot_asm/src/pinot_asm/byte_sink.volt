module pinot_asm.byte_sink;

import watt.text.sink;

struct ByteSink = mixin SinkStruct!u8;