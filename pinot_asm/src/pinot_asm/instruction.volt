module pinot_asm.instruction;

import core.exception;
import watt.text.string;

import pinot_asm.location;

abstract class Inst {
    abstract fn toBytes() u8[];

    fn isError() bool {
        return false;
    }
}

class ErrorInst : Inst {
private:
    message: string;

public:
    this(string message) {
        this.message = message;
    }

    override fn isError() bool {
        return true;
    }

    override fn toString() string {
        return "Error: " ~ message;
    }

    override fn toBytes() u8[] {
        throw new Exception("Tried to convert ErrorInst to bytes.");
    }
}

class NopInst : Inst {
    override fn toBytes() u8[] {
        return [cast(u8)0x00];
    }
}

class HltInst : Inst {
    override fn toBytes() u8[] {
        return [cast(u8)0x01];
    }
}