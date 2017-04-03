
#if !defined( _AESTAB_H )
#define _AESTAB_H

#if defined(__cplusplus)
extern "C" {
#endif

#define t_dec(m,n) t_##m##n
#define t_set(m,n) t_##m##n
#define t_use(m,n) t_##m##n

#if defined(FIXED_TABLES)
#  if !defined( __GNUC__ ) && (defined( __MSDOS__ ) || defined( __WIN16__ ))
/*   make tables far data to avoid using too much DGROUP space (PG) */
#    define CONST const far
#  else
#    define CONST const
#  endif
#else
#  define CONST
#endif

#if defined(DO_TABLES)
#  define EXTERN
#else
#  define EXTERN extern
#endif

#if defined(_MSC_VER) && defined(TABLE_ALIGN)
#define ALIGN __declspec(align(TABLE_ALIGN))
#else
#define ALIGN
#endif

#if defined( __WATCOMC__ ) && ( __WATCOMC__ >= 1100 )
#  define XP_DIR __cdecl
#else
#  define XP_DIR
#endif

#if defined(DO_TABLES) && defined(FIXED_TABLES)
#define d_1(t,n,b,e)       EXTERN ALIGN CONST XP_DIR t n[256]    =   b(e)
#define d_4(t,n,b,e,f,g,h) EXTERN ALIGN CONST XP_DIR t n[4][256] = { b(e), b(f), b(g), b(h) }
EXTERN ALIGN CONST uint_32t t_dec(r,c)[RC_LENGTH] = rc_data(w0);
#else
#define d_1(t,n,b,e)       EXTERN ALIGN CONST XP_DIR t n[256]
#define d_4(t,n,b,e,f,g,h) EXTERN ALIGN CONST XP_DIR t n[4][256]
EXTERN ALIGN CONST uint_32t t_dec(r,c)[RC_LENGTH];
#endif

#if defined( SBX_SET )
    d_1(uint_8t, t_dec(s,box), sb_data, h0);
#endif
#if defined( ISB_SET )
    d_1(uint_8t, t_dec(i,box), isb_data, h0);
#endif

#if defined( FT1_SET )
    d_1(uint_32t, t_dec(f,n), sb_data, u0);
#endif
#if defined( FT4_SET )
    d_4(uint_32t, t_dec(f,n), sb_data, u0, u1, u2, u3);
#endif

#if defined( FL1_SET )
    d_1(uint_32t, t_dec(f,l), sb_data, w0);
#endif
#if defined( FL4_SET )
    d_4(uint_32t, t_dec(f,l), sb_data, w0, w1, w2, w3);
#endif

#if defined( IT1_SET )
    d_1(uint_32t, t_dec(i,n), isb_data, v0);
#endif
#if defined( IT4_SET )
    d_4(uint_32t, t_dec(i,n), isb_data, v0, v1, v2, v3);
#endif

#if defined( IL1_SET )
    d_1(uint_32t, t_dec(i,l), isb_data, w0);
#endif
#if defined( IL4_SET )
    d_4(uint_32t, t_dec(i,l), isb_data, w0, w1, w2, w3);
#endif

#if defined( LS1_SET )
#if defined( FL1_SET )
#undef  LS1_SET
#else
    d_1(uint_32t, t_dec(l,s), sb_data, w0);
#endif
#endif

#if defined( LS4_SET )
#if defined( FL4_SET )
#undef  LS4_SET
#else
    d_4(uint_32t, t_dec(l,s), sb_data, w0, w1, w2, w3);
#endif
#endif

#if defined( IM1_SET )
    d_1(uint_32t, t_dec(i,m), mm_data, v0);
#endif
#if defined( IM4_SET )
    d_4(uint_32t, t_dec(i,m), mm_data, v0, v1, v2, v3);
#endif

#if defined(__cplusplus)
}
#endif

#endif
