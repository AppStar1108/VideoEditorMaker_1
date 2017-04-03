
#ifndef _HMAC_H
#define _HMAC_H

#include <memory.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define USE_SHA1

#if !defined(USE_SHA1) && !defined(USE_SHA256)
#error define USE_SHA1 or USE_SHA256 to set the HMAC hash algorithm
#endif

#ifdef USE_SHA1

#include "sha1.h"

#define HASH_INPUT_SIZE     SHA1_BLOCK_SIZE
#define HASH_OUTPUT_SIZE    SHA1_DIGEST_SIZE
#define sha_ctx             sha1_ctx
#define sha_begin           sha1_begin
#define sha_hash            sha1_hash
#define sha_end             sha1_end

#endif

#ifdef USE_SHA256

#include "sha2.h"

#define HASH_INPUT_SIZE     SHA256_BLOCK_SIZE
#define HASH_OUTPUT_SIZE    SHA256_DIGEST_SIZE
#define sha_ctx             sha256_ctx
#define sha_begin           sha256_begin
#define sha_hash            sha256_hash
#define sha_end             sha256_end

#endif

#define HMAC_OK                0
#define HMAC_BAD_MODE         -1
#define HMAC_IN_DATA  0xffffffff

typedef struct
{   unsigned char   key[HASH_INPUT_SIZE];
    sha_ctx         ctx[1];
    unsigned long   klen;
} hmac_ctx;

void hmac_sha_begin(hmac_ctx cx[1]);

int  hmac_sha_key(const unsigned char key[], unsigned long key_len, hmac_ctx cx[1]);

void hmac_sha_data(const unsigned char data[], unsigned long data_len, hmac_ctx cx[1]);

void hmac_sha_end(unsigned char mac[], unsigned long mac_len, hmac_ctx cx[1]);

void hmac_sha(const unsigned char key[], unsigned long key_len,
          const unsigned char data[], unsigned long data_len,
          unsigned char mac[], unsigned long mac_len);

#if defined(__cplusplus)
}
#endif

#endif
