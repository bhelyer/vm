module main;

import watt.io;
import watt.io.file;

import pinot_asm.token;
import pinot_asm.parser;
import pinot_asm.byte_sink;
import pinot_asm.instruction;
import pinot_asm.symbols;

int main(args: string[]) {
	// Validate arguments.
	if (args.length != 2) {
		error.writefln("Usage: %s asm_file", args[0]);
		return 1;
	}

	// Parse the input file into a list of tokens.
	tokens: Token[] = lex(args[1], cast(string)read(args[1]));

	// Check the tokens for an error token.
	foreach (token; tokens) {
		if (token.type == Token.Type.Error) {
			error.writefln("%s:%s: error: %s", token.loc.filename, token.loc.line, token.value);
			return 1;
		}
	}

	// Parse the list of tokens into a list of instructions.
	insts: Inst[] = parse(tokens);

	// Pass 1: Load symbols into the symbol table.
	syms := new Symbols();
	foreach (inst; insts) {
		if (inst.label.length > 0) {
			syms.associate(inst.label, inst);
		}
	}

	// Pass 2: Emit code instructions.
	codeSink: ByteSink;
	dataSink: ByteSink;
	foreach (inst; insts) {
		if (inst.isError()) {
			error.writefln("? %s", inst.toString());
			return 1;
		}
		if (inst.storage) {
			dataSink.append(inst.toBytes(syms));
		} else {
			codeSink.append(inst.toBytes(syms));
		}
	}

	// Write the bytes into an output file.
	write(cast(void[])(codeSink.toArray() ~ dataSink.toArray()), "a.bin");
	return 0;
}