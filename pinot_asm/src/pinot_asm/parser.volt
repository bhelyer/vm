module pinot_asm.parser;

import core.exception;
import watt.text.sink;
import watt.text.format;

import pinot_asm.token;
import pinot_asm.instruction;
import pinot_asm.register;

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
		case "ld":
			isink.sink(parseLd(tokens, ref index));
			break;
		case "const":
			isink.sink(parseConst(tokens, ref index));
			break;
		default:
			isink.sink(new ErrorInst(format("Unexpected token: %s.", tokens[index])));
			return isink.toArray();
		}
	}
	return isink.toArray();
}

private:

fn expectIdent(str: string, tokens: Token[], ref index: size_t) {
	next := tokens[index];
	if (next.type != Token.Type.Identifier || next.value != str) {
		throw new Exception(format("Unexpected token: '%s'.", next));
	}
	++index;
}

fn expect(type: Token.Type, tokens: Token[], ref index: size_t) Token {
	next := tokens[index];
	if (next.type != type) {
		throw new Exception(format("Unexpected token: '%s'.", next));
	}
	++index;
	return next;
}

fn parseLd(tokens: Token[], ref index: size_t) Inst {
	try {
		expectIdent("ld", tokens, ref index);
		dstTok := expect(Token.Type.Identifier, tokens, ref index);
		expect(Token.Type.Comma, tokens, ref index);
		srcTok := expect(Token.Type.IntegerLiteral, tokens, ref index);
		// TODO: Large integers.
		if (srcTok.ivalue >= 256) {
			return new ErrorInst("Unimplemented: loading large integers.");
		}
		return new LdInst(dstTok.value.toRegister(), cast(u8)srcTok.ivalue);
	} catch (Exception e) {
		return new ErrorInst(e.msg);
	}
	assert(false);
}

fn parseConst(tokens: Token[], ref index: size_t) Inst {
	try {
		expectIdent("const", tokens, ref index);
		nameTok := expect(Token.Type.Identifier, tokens, ref index);
		expect(Token.Type.Equal, tokens, ref index);
		valueTok := expect(Token.Type.StringLiteral, tokens, ref index);
		value := new u8[](valueTok.value.length);
		for (i: size_t = 0; i < valueTok.value.length; ++i) {
			value[i] = cast(u8)valueTok.value[i];
		}
		return new ConstInst(nameTok.value, value);
	} catch (Exception e) {
		return new ErrorInst(e.msg);
	}
	assert(false);
}