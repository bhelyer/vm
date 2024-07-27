module pinot_asm.instruction;

import core.exception;
import watt.text.string;

import pinot_asm.location;
import pinot_asm.register;

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
		return [0x00_u8];
	}
}

class HltInst : Inst {
	override fn toBytes() u8[] {
		return [0x01_u8];
	}
}

class LdInst : Inst {
private:
	bytes: u8[];

public:
	// Load a register with a constant u8 value.
	this(dst: Register, value: u8) {
		bytes = [cast(u8)0x02, cast(u8)dst, value];
	}

	override fn toBytes() u8[] {
		return bytes;
	}
}