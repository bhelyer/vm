module main;

import watt.io;
import watt.io.file;

import pinot_asm.token;

int main(args: string[])
{
    if (args.length != 2)
    {
        error.writefln("Usage: %s asm_file", args[0]);
        return 1;
    }
    tokens: Token[] = lex(args[1], cast(string)read(args[1]));
    foreach (token; tokens)
    {
        if (token.type == Token.Type.Error)
        {
            error.writefln("%s:%s: error: %s", token.loc.filename, token.loc.line, token.value);
        }
        else
        {
            writefln("TOKEN: %s, %s (%s)", token.type, token.value, token.ivalue);
        }
    }
    return 0;
}