module pinot_asm.parser;

import watt.text.sink;
import watt.text.format;

import pinot_asm.token;
import pinot_asm.instruction;

struct InstSink = mixin SinkStruct!Inst;

fn parse(tokens: Token[]) Inst[] {
    isink: InstSink;
    index: size_t = 0;
    while (index < tokens.length) {
        switch (tokens[index].value) {
        case "hlt":
            isink.sink(new HltInst());
            ++index;
            break;
        default:
            isink.sink(new ErrorInst(format("Unexpected token: %s.", tokens[index].type)));
            return isink.toArray();
        }
    }
    return isink.toArray();
}