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
    tokens: Token[] = lex(cast(string)read(args[1]));
    foreach (token; tokens)
    {
        writefln("TOKEN: %s, %s (%s)", token.type, token.value, token.ivalue);
    }
    return 0;
}