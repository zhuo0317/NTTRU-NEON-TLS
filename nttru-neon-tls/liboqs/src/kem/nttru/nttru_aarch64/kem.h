#ifndef KEM_H
#define KEM_H

#include "params.h"

#define CRYPTO_SECRETKEYBYTES  NTTRU_SECRETKEYBYTES
#define CRYPTO_PUBLICKEYBYTES  NTTRU_PUBLICKEYBYTES
#define CRYPTO_CIPHERTEXTBYTES NTTRU_CIPHERTEXTBYTES
#define CRYPTO_BYTES           NTTRU_SSBYTES


int NTTRU_AARCH64_crypto_kem_keypair(unsigned char *pk, unsigned char *sk);
int NTTRU_AARCH64_crypto_kem_enc(unsigned char *c,
                   unsigned char *k,
                   const unsigned char *pk);
int NTTRU_AARCH64_crypto_kem_dec(unsigned char *k,
                   const unsigned char *c,
                   const unsigned char *sk);

#endif
