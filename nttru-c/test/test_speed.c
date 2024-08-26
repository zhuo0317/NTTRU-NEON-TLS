#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "cpucycles.h"
#include <stdint.h>
#include <stdio.h>
#include "../params.h"
#include "../fq.h"
#include "../poly.h"
#include "../ntt.h"
#include "../kem.h"
#include "speed.h"
#include "../randombytes.h"

#define NTESTS 100000
#define KYBER_SYMBYTES 32

uint64_t t[NTESTS];
uint8_t seed[KYBER_SYMBYTES] = {0};

int main(void)
{
  unsigned int i;
  poly a, b, c2;
  uint64_t cycles1, cycles2;
  /* NTT ops*/
  for(i=0;i<NTESTS;i++) {
    cycles1 = cpucycles();
    poly_ntt(&a, &a);
    cycles2 = cpucycles();
    t[i] = cycles2-cycles1;
  }
  print_results("ntt_c: ", t, NTESTS);

  for(i=0;i<NTESTS;i++) {
    cycles1 = cpucycles();
    poly_invntt(&c2, &c2);
    cycles2 = cpucycles();
    t[i] = cycles2-cycles1;
  }
  print_results("invntt_c: ", t, NTESTS);

    for(i=0;i<NTESTS;i++) {
    cycles1 = cpucycles();
    poly_basemul(&c2, &a, &b);
    cycles2 = cpucycles();
    t[i] = cycles2-cycles1;
  }
  print_results("basemul_c: ", t, NTESTS);


    for(i=0;i<NTESTS;i++) {
    cycles1 = cpucycles();
    poly_baseinv(&b, &a);
    cycles2 = cpucycles();
    t[i] = cycles2-cycles1;
  }
  print_results("baseinv_c: ", t, NTESTS);

  unsigned char k1[SHAREDKEYBYTES], k2[SHAREDKEYBYTES], c[CIPHERTEXTBYTES];
  unsigned char pk[PUBLICKEYBYTES], sk[SECRETKEYBYTES];

  for(i=0;i<NTESTS;i++) {
    cycles1 = cpucycles();
    crypto_kem_keypair(pk, sk);
    cycles2 = cpucycles();
    t[i] = cycles2-cycles1;
  }
  print_results("kem_keypair_c: ", t, NTESTS);

  for(i=0;i<NTESTS;i++) {
    cycles1 = cpucycles();
    crypto_kem_enc(c, k1, pk);
    cycles2 = cpucycles();
    t[i] = cycles2-cycles1;
  }
  print_results("kem_encrypt_c: ", t, NTESTS);

  for(i=0;i<NTESTS;i++) {
    cycles1 = cpucycles();
    crypto_kem_dec(k2, c, sk);
    cycles2 = cpucycles();
    t[i] = cycles2-cycles1;
  }
  print_results("kem_decrypt_c: ", t, NTESTS);

  for(i=0;i<NTESTS;i++) {
    cycles1 = cpucycles();
    poly_reduce(&a);
    cycles2 = cpucycles();
    t[i] = cycles2-cycles1;
  }
  print_results("reduce_c: ", t, NTESTS);

  for(i=0;i<NTESTS;i++) {
    cycles1 = cpucycles();
    poly_freeze(&a);
    cycles2 = cpucycles();
    t[i] = cycles2-cycles1;
  }
  print_results("freeze_c: ", t, NTESTS);

  return 0;
}
