#ifndef PARAMS_H
#define PARAMS_H

#define NTTRU_NAMESPACE(s) NTTRU_AARCH64_##s

#define NTTRU_N 768
#define NTTRU_Q 7681
#define NTTRU_LOGQ 13
#define NTTRU_ROOT_OF_UNITY 20


#define NTTRU_SYMBYTES 32   /* size in bytes of hashes, and seeds */
#define NTTRU_SSBYTES  32   /* size in bytes of shared key */
#define NTTRU_COINBYTES (NTTRU_N/2)
#define NTTRU_MSGBYTES (NTTRU_N/4)
#define NTTRU_PUBLICKEYBYTES (NTTRU_LOGQ*NTTRU_N/8)
#define NTTRU_SECRETKEYBYTES (NTTRU_LOGQ*NTTRU_N/8 + NTTRU_PUBLICKEYBYTES)
#define NTTRU_CIPHERTEXTBYTES (NTTRU_LOGQ*NTTRU_N/8)



#define crypto_kem_keypair NTTRU_NAMESPACE(crypto_kem_keypair)
int crypto_kem_keypair(unsigned char *pk, unsigned char *sk);

#define crypto_kem_enc NTTRU_NAMESPACE(crypto_kem_enc)
int crypto_kem_enc(unsigned char *ct,unsigned char *k,const unsigned char *pk);

#define crypto_kem_dec NTTRU_NAMESPACE(crypto_kem_dec)
int crypto_kem_dec(unsigned char *k,const unsigned char *ct,const unsigned char *sk);

#endif
