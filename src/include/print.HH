#ifndef PRINT_HH
#define PRINT_HH

#include "../../../holyc-lang/src/holyc-lib/tos.HH"

public U0 Print(U8 *str)
{
    write(1, str, StrLen(str));
}

#endif