module pinot_asm.instruction;

import core.exception;
import watt.text.string;

import pinot_asm.location;
import pinot_asm.register;
import pinot_asm.symbols;

// Individual components of an assembly program.
// These don't always correspond to actual instructions.
abstract class Inst {
	// Get the representation of this instruction.
	abstract fn toBytes(syms: Symbols) u8[];

	// Does this instruction represent an error?
	fn isError() bool {
		return false;
	}

	// If this string is non-empty, this label points at this instruction.
	@property fn label() string {
		return "";
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

	override fn toBytes(syms: Symbols) u8[] {
		throw new Exception("Tried to convert ErrorInst to bytes.");
	}
}

class NopInst : Inst {
	override fn toBytes(syms: Symbols) u8[] {
		return [0x00_u8];
	}
}

class HltInst : Inst {
	override fn toBytes(syms: Symbols) u8[] {
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

	override fn toBytes(syms: Symbols) u8[] {
		return bytes;
	}
}

class ConstInst : Inst {
private:
	name: string;
	bytes: u8[];

public:
	this(name: string, value: u8[]) {
		this.name = name;
		this.bytes = value;
	}

	override fn toBytes(syms: Symbols) u8[] {
		return bytes;
	}

	override @property fn label() string {
		return name;
	}
}