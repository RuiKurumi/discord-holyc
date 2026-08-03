#ifndef STRING_HH
#define STRING_HH

Bool StrContains(
    U8 *haystack,
    U8 *needle
);

I32 StrCompare(
    U8 *a,
    U8 *b
);

U8 *StrCopy(
    U8 *source
);

U0 MemCopy(
    U0 *dest,
    U0 *src,
    I64 length
);

#endif