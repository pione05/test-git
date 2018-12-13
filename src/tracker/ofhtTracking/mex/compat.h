
#ifndef _COMPAT_H_
#define _COMPAT_H_

//Type definition
#ifdef _MSC_VER 
    typedef __int32 int32_t;
    typedef unsigned __int32 uint32_t;
    #define isnan _isnan
#else
    
    #include <stdint.h>
#endif

//Function definition
#ifdef _MSC_VER 
    inline double round(double value) 
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

//Temporary
#if defined(__OS2__) || defined(__WINDOWS__) || defined(WIN32) || defined(_MSC_VER) 
#define isnan(x) _isnan(x)
#define isinf(x) (!_finite(x))
#endif

#if defined (_MSC_VER)
#define INFINITY (DBL_MAX+DBL_MAX)
#define NAN (INFINITY-INFINITY)
#endif
    

#endif  //_COMPAT_H_
