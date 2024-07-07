module pinot_asm.token;

import watt.text.ascii;

class Token
{
public:
    enum Type
    {
        Error,
        Identifier,
        StringLiteral,
        IntegerLiteral,
        Const,
        Equal,
        Comma,
        Length, // identifier.length
    }

    this(type: Token.Type, value: string)
    {
        this.type = type;
        this.value = value;
    }

    type: Type;
    value: string;
}

fn lex(str: string) Token[]
{
    tokens: Token[];
    for (i: size_t = 0; i < str.length; /* no increment */)
    {
        while (isWhite(str[i]))
        {
            ++i;
        }
        c := str[i];

        if (isAlpha(c))
        {
            tokens ~= lexFromLetter(str, ref i);
            continue;
        }

        if (c == '"')
        {
            tokens ~= lexString(str, ref i);
            continue;
        }

        switch (c)
        {
        case '=':
            tokens ~= new Token(Token.Type.Equal, str[i .. i + 1]);
            break;
        case ',':
            tokens ~= new Token(Token.Type.Comma, str[i .. i + 1]);
            break;
        default:
            tokens ~= new Token(Token.Type.Error, str[i .. $]);
            return tokens;
        }

        ++i;
    }
    return tokens;
}

private:

fn lexFromLetter(str: string, ref i: size_t) Token
{
    start_i := i;

    while (isAlpha(str[i]) && i < str.length)
    {
        ++i;
    }
    word := str[start_i .. i];
    if (word == "const")
    {
        return new Token(Token.Type.Const, word);
    }
    else
    {
        return new Token(Token.Type.Identifier, word);
    }
}

fn lexString(str: string, ref i: size_t) Token
{
    start_i := ++i;
    while (i < str.length && str[i] != '"')
    {
        ++i;
    }
    word := str[start_i .. i];
    ++i; // Skip the last quote.
    return new Token(Token.Type.StringLiteral, word);
}