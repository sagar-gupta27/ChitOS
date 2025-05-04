#include "x86.h"
#include "stdio.h"

typedef unsigned char bool;

#define LENGTH_DEFAULT 0
#define LENGTH_HALF_HALF 1
#define LENGTH_HALF 2
#define LENGTH_LONG 3
#define LENGTH_LONG_LONG 4
#define LENGTH_LONG_DOUBLE 5

#define WIDTH_STAR -1
#define NO_WIDTH 0

#define NO_PREC 0
#define PREC_MIN_DIGITS 1
#define PREC_DECI_DIGITS 2
#define PREC_SEG_DIGITS 3
#define PREC_MAX_CHAR 4
#define PREC_NOTHING 5
#define PREC_STAR 6

void putc(char c)
{
    x86_Video_WriteCharTeletype(c, 0);
}

void puts(const char *str)
{
    while (*str)
    {
        putc(*str++);
    }
}

bool isDigit(char ch)
{
    if (ch == '0' || ch == '1' || ch == '2' || ch == '3' || ch == '4' || ch == '5' || ch == '6' || ch == '7' || ch == '8' || ch == '9')
    {
        return true;
    }

    return false;
}

const char g_HexChars[] = "0123456789abcdef";

typedef struct
{
    bool hash;
    bool zero;
    bool minus;
    bool plus;
    bool space;
} printf_flags;

int numDigits(int digit)
{
    int ans = 0;

    if (digit == 0)
        return 1;
    while (digit)
    {
        digit /= 10;
        ans++;
    }
   
    return ans;
}

void intToChar(unsigned long long number)
{
    char buffer[32];
    int pos = 0;
    int radix = 10;
    do
    {
        uint32_t rem;
        x86_div64_32(number, radix, &number, &rem);
        buffer[pos++] = g_HexChars[rem];
    } while (number > 0);

    // print number in reverse order
    while (--pos >= 0)
        putc(buffer[pos]);

    putc('\r');
    putc('\n');
}

int *print_number(int *argp, printf_flags flags, int width, int prec, int length, int radix, int sign, int precType)
{

    //%flags|width|.precision|length|specifier
    // create a buffer of charcters and then pass it to assembly function one by one
    char buffer[32];
    int pos = 0;
    unsigned long long number;

    // printf("checking the working %0*.*6d",7,7,89);

    int leadingZeros = 0;
    int numSpaces = 0;
    int zero_or_space = -1;
    int extraChar = 0;
    int number_sign = 1; // positive
    int totalDigits = 0;
    int i = 0;

    // intToChar((unsigned long long )(*argp));
    if (width == WIDTH_STAR)
    {
        width = *(int *)argp;
        argp++;
    }

    if (prec == PREC_STAR)
    {
        prec = *(int *)argp;
        argp++;
    }

    totalDigits = numDigits(*(int *)argp);
    // intToChar(totalDigits);

    if (precType == PREC_MIN_DIGITS)
    {
        if (totalDigits < prec)
            leadingZeros = prec - totalDigits;
    }

    if (width > prec)
        extraChar = width - prec;

    if (flags.space && !flags.plus)
    {
        extraChar--;
    }

    switch (length)
    {
    case LENGTH_DEFAULT:
    case LENGTH_HALF:
    case LENGTH_HALF_HALF:
        if (sign)
        {
            int n = *(int *)argp;
            if (n < 0)
            {
                n = -n;
                number_sign = -1; // negative number
            }

            number = (unsigned long long)n;
        }
        else
        {
            number = *(unsigned int *)argp;
        }
        argp++;
        break;
    case LENGTH_LONG:
        if (sign)
        {
            long int n = *(long int *)argp;
            if (n < 0)
            {
                n = -n;
                number_sign = -1;
            }
            number = (unsigned long long)n;
        }
        else
        {
            number = *(unsigned long int *)argp;
        }
        argp += 2;
        break;
    case LENGTH_LONG_LONG:
        if (sign)
        {
            long long int n = *(long long int *)argp;
            if (n < 0)
            {
                n = -n;
                number_sign = -1;
            }
            number = (unsigned long long)n;
        }
        else
        {
            number = *(unsigned long long int *)argp;
        }
        argp += 4;
        break;

    default:
        break;
    }

    // convert number to ASCII
    do
    {
        uint32_t rem;
        x86_div64_32(number, radix, &number, &rem);
        buffer[pos++] = g_HexChars[rem];
    } while (number > 0);

    // add extrac characters
    extraChar -= totalDigits;
    // intToChar(totalDigits);
    // intToChar(extraChar);
    if (extraChar > 0)
    {

        if (flags.minus)
        {
            for (i = 0; i < extraChar; i++)
            {
                buffer[pos++] = ' ';
            }
        }
        else
        {
            for (i = 0; i < extraChar; i++)
                buffer[pos++] = '0';
        }
    }

    // add sign
    if (sign && number_sign < 0)
        buffer[pos++] = '-';

    // print number in reverse order
    while (--pos >= 0)
        putc(buffer[pos]);

    
    return argp;
}

bool isFlag(char c){
    if(c == ' ' || c == '-' || c == '+' || c == '#' || c == '0')
    return true;

    return false;
}

int printf(const char *format, ...)
{
    // parse the format string and print the arguments
    const char *p = format;
    int *argp = (int *)&format;
    int width = -1;     // not specified
    int prec = NO_PREC; // not specified
    int length = LENGTH_DEFAULT;
    int radix = 10;
    int precType = NO_PREC;
    bool sign = false;
    printf_flags flags;
    flags.hash = false;
    flags.zero = false;
    flags.plus = false;
    flags.minus = false;
    flags.space = false;

    argp++;

    // intToChar((unsigned long long)(*argp));
    while (*p)
    {
        // printf("Formatted %% %c %s %ls\r\n", 'a', "string", "far_str");
        switch (*p)
        {
        case '%': //  start of specifier flags|width|.precision|length
            p++;

            // check for flags
            if (*p == '%')
            {
                putc('%');
                p++;
            }
            else
            {
                while (*p && isFlag(*p))
                {
                    if (*p == ' ')
                    {
                        flags.space = true;
                        p++;
                    }
                    if (*p == '-')
                    {
                        flags.minus = true;
                        p++;
                    }
                    if (*p == '+')
                    {
                        flags.plus = true;
                        p++;
                    }
                    if (*p == '#')
                    {
                        flags.hash = true;
                        p++;
                    }

                    if (*p == '0')
                    {
                        flags.zero = true;
                        p++;
                    }

                    
                }

                if (*p == '*') // width will come from argument
                {
                    width = WIDTH_STAR;
                    p++;
                }
                else
                {
                    width = 0;
                    while (*p && isDigit(*p))
                    {
                        width = width * 10 + *p - '0';
                        p++;
                    }
                }
                // check for precision

                if (*p == '.')
                {
                    p++;
                    if (*p == '*') // precison will come from argument
                    {
                        prec = PREC_STAR;
                        p++;
                    }
                    else
                    {
                        while (*p && isDigit(*p))
                        {
                            prec = prec * 10 + *p - '0';
                            p++;
                        }
                    }
                }

                // Check for length
                switch (*p)
                {
                case 'h':
                    if (*(p + 1) == 'h')
                    {
                        length = LENGTH_HALF_HALF;
                        p += 2;
                    }
                    else
                    {
                        length = LENGTH_HALF;
                        p++;
                    }
                    break;
                case 'l':
                    if (*(p + 1) == 'l')
                    {
                        length = LENGTH_LONG_LONG;
                        p += 2;
                    }
                    else
                    {
                        length = LENGTH_LONG;
                        p++;
                    }
                    break;
                case 'L':
                    length = LENGTH_LONG_DOUBLE;
                    break;
                }

                // check for the specifier
                switch (*p)
                {
                case 'd':
                case 'i':
                    radix = 10, sign = true;
                    precType = PREC_MIN_DIGITS;
                    argp = print_number(argp, flags, width, prec, length, radix, sign, precType);
                    p++;
                    break;
                case 'u':
                    radix = 10, sign = false;
                    precType = PREC_MIN_DIGITS;
                    argp = print_number(argp, flags, width, prec, length, radix, sign, precType);
                    p++;
                    break;
                case 'x':
                case 'X':
                case 'p':
                    p++;
                    precType = PREC_MIN_DIGITS;
                    radix = 16, sign = false;
                    argp = print_number(argp, flags, width, prec, length, radix, sign, precType);
                    break;
                case 'f':
                case 'F':
                    p++;
                    precType = PREC_DECI_DIGITS;
                    radix = 10, sign = true;
                    argp = print_number(argp, flags, width, prec, length, radix, sign, precType);
                    break;
                case 'a':
                case 'A':
                    p++;
                    precType = PREC_DECI_DIGITS;
                    radix = 16, sign = true;
                    argp = print_number(argp, flags, width, prec, length, radix, sign, precType);
                    break;
                case 'c':
                    p++;
                    putc(*argp);
                    argp++;
                    break;
                case 's':
                    p++;
                    precType = PREC_MAX_CHAR;
                    puts(*(char **)argp);
                    break;
                case 'o':
                    p++;
                    precType = PREC_MIN_DIGITS;
                    radix = 8, sign = false;
                    argp = print_number(argp, flags, width, prec, length, radix, sign, precType);
                    break;
                case 'e':
                case 'E':
                    p++;
                    precType = PREC_DECI_DIGITS;
                case 'g':
                case 'G':
                    p++;
                    precType = PREC_SEG_DIGITS;
                default:
                    break;
                }
            }

            break;
        default:
            putc(*p);
            p++;
            break;
        }
    }

    return 0;
}
