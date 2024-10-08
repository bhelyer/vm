module pinot_asm.instruction;

import core.exception;
import watt.text.string;

import pinot_asm.location;
import pinot_asm.register;
import pinot_asm.symbols;
import pinot_asm.byteutils;

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

	// If non-null, this instruction needs to be resolved.
	@property fn neededSymbol() string {
		return null;
	}

	// Supply the symbol required from neededSymbol. (Dubious API, revise.)
	fn resolve(symbol: string, addr: u64) {
		throw new Exception("Resolution unrequired.");
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
	dst: Register;
	symbol: string;

public:
	// Load a register with a constant u8 value.
	this(loc: Location, dst: Register, value: u8) {
		super(loc);
		this.dst = dst;
		bytes = [cast(u8)0x02, cast(u8)dst, value];
	}

	// Load a register with an address from a label.
	this(loc: Location, dst: Register, symbol: string) {
		super(loc);
		this.dst = dst;
		this.symbol = symbol;
	}

	override fn toBytes(syms: Symbols) u8[] {
		return bytes;
	}

	override @property fn length() size_t {
		return bytes.length;
	}

	override @property fn neededSymbol() string {
		return symbol;
	}

	override fn resolve(symbol: string, addr: u64) {
		if (this.symbol == null) {
			throw new Exception("Resolution unrequired.");
		}
		if (symbol != this.symbol) {
			throw new Exception("Incorrect symbol.");
		}
		bytes = [cast(u8)0x03, cast(u8)dst] ~ toArray(addr);
		this.symbol = null;
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