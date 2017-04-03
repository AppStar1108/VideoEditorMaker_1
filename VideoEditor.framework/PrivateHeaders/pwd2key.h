
#ifndef PWD2KEY_H
#define PWD2KEY_H

#if defined(__cplusplus)
extern "C"
{
#endif

void derive_key(
        const unsigned char pwd[],   /* the PASSWORD, and   */
        unsigned int pwd_len,        /*    its length       */ 
        const unsigned char salt[],  /* the SALT and its    */
        unsigned int salt_len,       /*    length           */
        unsigned int iter,      /* the number of iterations */
        unsigned char key[],    /* space for the output key */
        unsigned int key_len);  /* and its required length  */

#if defined(__cplusplus)
}
#endif

#endif
