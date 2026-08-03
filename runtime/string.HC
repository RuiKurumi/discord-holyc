#include "../include/string.HH"

Bool StrContains(
    U8 *haystack,
    U8 *needle
)
{
    I64 i;
    I64 j;

    if(!haystack || !needle)
        return FALSE;

    for(i = 0; haystack[i]; i++)
    {
        j = 0;

        while(
            needle[j] &&
            haystack[i+j] == needle[j]
        )
        {
            j++;
        }

        if(!needle[j])
            return TRUE;
    }

    return FALSE;
}
I32 StrCompare(
    U8 *a,
    U8 *b
)
{
    while(*a && *b)
    {
        if(*a != *b)
            return *a - *b;

        a++;
        b++;
    }

    return *a - *b;
}
U8 *StrCopy(
    U8 *source
)
{
    I64 length;
    I64 i;
    U8 *dest;


    length = 0;

    while(source[length])
    {
        length++;
    }


    dest = MAlloc(length + 1);

    if(!dest)
        return NULL;


    for(i = 0; i < length; i++)
    {
        dest[i] = source[i];
    }


    dest[length] = 0;


    return dest;
}
U0 MemCopy(
    U0 *dest,
    U0 *src,
    I64 length
)
{
    I64 i;

    U8 *d = dest;
    U8 *s = src;

    for(i = 0; i < length; i++)
    {
        d[i] = s[i];
    }
}