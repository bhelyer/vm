module pinot_asm.symbols;

import pinot_asm.instruction;

class Symbol {
private:
	inst: Inst;
	len: size_t;

public:
	this(inst: Inst, len: size_t) {
		this.inst = inst;
		this.len = len;
	}
}

class Symbols {
private:
	symbols: Inst[string];

public:
	fn lookup(name: string) Inst {
		return symbols.get(name, null);
	}

	fn associate(name: string, inst: Inst) {
		symbols[name] = inst;
	}
}