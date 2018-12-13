// file which tries to add compatibility with other operating
// systems (aside from Linux)

#ifdef _MSC_VER 
// code for windows
typedef __int32 int32_t;
typedef unsigned __int32 uint32_t;
#define isnan _isnan
#else
// code for Linux
#include <stdint.h>
#endif

#ifdef _MSC_VER 
inline int round(double value) 
{
    return (int)(value + (value >= 0 ? 0.5 : -0.5));
}

#include <string.h>
inline void bzero(void *s, size_t n)
{
    memset(s, 0, n);
        
    return; 
}

#define snprintf _snprintf

#endif    