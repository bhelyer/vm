module pinot_asm.instruction;

import core.exception;
import watt.text.string;

import pinot_asm.location;
import pinot_asm.register;
import pinot_asm.symbols;

// Individual components of an assembly program.
// These don't always correspond to actual instructions.
abstract class Inst {
	this(loc: Location) {
		this.loc = loc;
	}

	// Get the representation of this instruction.
	abstract fn toBytes(syms: Symbols) u8[];

	// How many bytes does this instruction take up?
	@property fn length() size_t {
		return 0;
	}

	// Does this instruction represent an error?
	fn isError() bool {
		return false;
	}

	// If this string is non-empty, this label points at this instruction.
	@property fn label() string {
		return "";
	}

	// If true, this instruction is storage (and should be emitted last).
	@property fn storage() bool {
		return false;
	}

	loc: Location;
}

class ErrorInst : Inst {
private:
	message: string;

public:
	this(loc: Location, string message) {
		super(loc);
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
	this(loc: Location) {
		super(loc);
	}

	override fn toBytes(syms: Symbols) u8[] {
		return [0x00_u8];
	}

	override @property fn length() size_t {
		return 1;
	}
}

class HltInst : Inst {
	this(loc: Location) {
		super(loc);
	}

	override fn toBytes(syms: Symbols) u8[] {
		return [0x01_u8];
	}

	override @property fn length() size_t {
		return 1;
	}
}

class LdInst : Inst {
private:
	bytes: u8[];

public:
	// Load a register with a constant u8 value.
	this(loc: Location, dst: Register, value: u8) {
		super(loc);
		bytes = [cast(u8)0x02, cast(u8)dst, value];
	}

	override fn toBytes(syms: Symbols) u8[] {
		return bytes;
	}

	override @property fn length() size_t {
		return bytes.length;
	}
}

class ConstInst : Inst {
private:
	name: string;
	bytes: u8[];

public:
	this(loc: Location, name: string, value: u8[]) {
		super(loc);
		this.name = name;
		this.bytes = value;
	}

	override fn toBytes(syms: Symbols) u8[] {
		return bytes;
	}

	override @property fn length() size_t {
		return bytes.length;
	}

	override @property fn label() string {
		return name;
	}

	override @property fn storage() bool {
		return true;
	}
}