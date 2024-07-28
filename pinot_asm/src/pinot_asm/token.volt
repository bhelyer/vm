module pinot_asm.token;

import watt.conv;
import watt.text.ascii;
import watt.text.format;

import pinot_asm.location;

class Token {
public:
	enum Type {
		Error,
		Identifier,
		StringLiteral,
		IntegerLiteral,
		Equal,
		Comma,
		Dot,
	}

	this(type: Token.Type, value: string) {
		this.type = type;
		this.value = value;
	}

	this(loc: Location, type: Token.Type, value: string) {
		this.loc = loc;
		this.type = type;
		this.value = value;
	}

	override fn toString() string {
		return value;
	}

	loc: Location;
	type: Type;
	value: string;
	ivalue: u64;
}

fn lex(filename: string, str: string) Token[] {
	Location current_loc;
	current_loc.filename = filename;
	current_loc.line = 1;
	tokens: Token[];
	for (i: size_t = 0; i < str.length; /* no increment */) {
		while (i < str.length && isWhite(str[i])) {
			if (str[i] == '\n') {
				current_loc.line++;
			}
			++i;
		}
		if (i >= str.length) {
			break;
		}
		c := str[i];

		if (isAlpha(c)) {
			tokens ~= lexFromLetter(str, ref i);
			tokens[$ - 1].loc = current_loc;
			continue;
		}

		if (c == '0' && i + 1 != str.length && str[i + 1] == 'x') {
			i += 2; // Skip "0x"
			tokens ~= lexHexLiteral(str, ref i);
			tokens[$ - 1].loc = current_loc;
			continue;
		}

		if (isDigit(c)) {
			tokens ~= lexIntLiteral(str, ref i);
			tokens[$ - 1].loc = current_loc;
			continue;
		}

		if (c == '"') {
			tokens ~= lexString(str, ref i);
			tokens[$ - 1].loc = current_loc;
			continue;
		}

		switch (c) {
		case '=':
			tokens ~= new Token(Token.Type.Equal, str[i .. i + 1]);
			tokens[$ - 1].loc = current_loc;
			break;
		case ',':
			tokens ~= new Token(Token.Type.Comma, str[i .. i + 1]);
			tokens[$ - 1].loc = current_loc;
			break;
		case '.':
			tokens ~= new Token(Token.Type.Dot, str[i .. i + 1]);
			tokens[$ - 1].loc = current_loc;
			break;
		default:
			tokens ~= new Token(Token.Type.Error, format("Unexpected character: '%s' (Integer: %s)", c, cast(int)c));
			tokens[$ - 1].loc = current_loc;
			return tokens;
		}

		++i;
	}
	return tokens;
}

private:

fn lexFromLetter(str: string, ref i: size_t) Token {
	start_i := i;

	while (isAlphaNum(str[i]) && i < str.length) {
		++i;
	}
	word := str[start_i .. i];
	return new Token(Token.Type.Identifier, word);
}

fn lexString(str: string, ref i: size_t) Token {
	start_i := ++i;
	while (i < str.length && str[i] != '"') {
		++i;
	}
	word := str[start_i .. i];
	++i; // Skip the last quote.
	return new Token(Token.Type.StringLiteral, word);
}

fn lexHexLiteral(str: string, ref i: size_t) Token {
	start_i := i;
	while (i < str.length && isHexDigit(str[i])) {
		++i;
	}
	word := str[start_i .. i];
	try {
		token := new Token(Token.Type.IntegerLiteral, word);
		token.ivalue = toUlong(word, 16);
		return token;
	} catch (ConvException) {
		return new Token(Token.Type.Error, "Int parse failure: " ~ word);
	}
}

fn lexIntLiteral(str: string, ref i: size_t) Token {
	start_i := i;
	while (i < str.length && isDigit(str[i])) {
		++i;
	}
	word := str[start_i .. i];
	try {
		token := new Token(Token.Type.IntegerLiteral, word);
		token.ivalue = toUlong(word, 10);
		return token;
	} catch (ConvException) {
		return new Token(Token.Type.Error, "Int parse failure: " ~ word);
	}
}