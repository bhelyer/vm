module main;

import watt.io;

import pinot_asm.token;

int main()
{
    writeln("Hello, world.");
    tokens: Token[] = lex("const string hello = \"Hello, world.\"");
    foreach (token; tokens)
    {
        writefln("TOKEN: %s, %s", token.type,   token.value);
    }
    return 0;
}