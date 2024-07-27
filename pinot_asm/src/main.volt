module main;

import watt.io;
import watt.io.file;

import pinot_asm.token;
import pinot_asm.parser;
import pinot_asm.byte_sink;
import pinot_asm.instruction;

int main(args: string[]) {
	if (args.length != 2) {
		error.writefln("Usage: %s asm_file", args[0]);
		return 1;
	}
	tokens: Token[] = lex(args[1], cast(string)read(args[1]));
	error.writefln("Lexed %s tokens.", tokens.length);
	foreach (token; tokens) {
		if (token.type == Token.Type.Error) {
			error.writefln("%s:%s: error: %s", token.loc.filename, token.loc.line, token.value);
			return 1;
		}
	}

	bsink: ByteSink;
	insts: Inst[] = parse(tokens);
	error.writefln("Parsed %s instructions.", insts.length);
	foreach (inst; insts) {
		if (inst.isError()) {
			error.writefln("? %s", inst.toString());
			return 1;
		}
		bsink.append(inst.toBytes());
	}

	write(cast(void[])bsink.toArray(), "a.bin");
	return 0;
}