#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "cpucycles.h"
#include "speed.h"
#include "../randombytes.h"
#include "../params.h"
#include "../crypto_stream.h"
#include "../ntru.h"
#include "../poly.h"
#include "../ntt.h"

#define NTESTS 10000
#define HISTORY 512


int main(void) {
  unsigned int i, j;
  unsigned char coins[2*N];
  poly hhat, fhat, chat, m, m2;

  init_ntt();

  for(i = 0; i < NTESTS; ++i) {
    j = i % HISTORY;
    randombytes(coins, sizeof(coins));
    poly_short(&m, coins);
    ntru_keygen(&hhat, &fhat, coins + N/2);

    ntru_encrypt(&chat, &hhat, &m, coins + 3*N/2);

    ntru_decrypt(&m2, &chat, &fhat);

    for(j = 0; j < N; ++j)
      if(m.coeffs[j] != m2.coeffs[j])
        printf("Messages don't match: m[%u] = %hd != %hd\n",
               j, m.coeffs[j], m2.coeffs[j]);
  }
  return 0;
}
