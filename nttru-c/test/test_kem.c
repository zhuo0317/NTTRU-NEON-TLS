#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "cpucycles.h"
#include "speed.h"
#include "../randombytes.h"
#include "../params.h"
#include "../kem.h"
#include "../ntt.h"

#define NTESTS 10000
#define HISTORY 512



uint64_t t[NTESTS];
int main(void) {
  unsigned int i, j;
  unsigned char k1[SHAREDKEYBYTES], k2[SHAREDKEYBYTES], c[CIPHERTEXTBYTES];
  unsigned char pk[PUBLICKEYBYTES], sk[SECRETKEYBYTES];

  init_ntt();
    
for(i=0;i<NTESTS;i++) {
    crypto_kem_keypair(pk, sk);
    crypto_kem_enc(c, k1, pk);
    crypto_kem_dec(k2, c, sk);
    for(j = 0; j < SHAREDKEYBYTES; ++j)
      if(k1[j] != k2[j])
      {
        printf("Failure: Keys dont match: %hhx != %hhx!\n", k1[j], k2[j]);
      }
  }
  return 0;
}
