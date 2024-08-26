#include <stdint.h>
#include "params.h"
#include "randombytes.h"
#include "fq.h"

int16_t fqmontred(int32_t a) {
  int32_t t;
  int16_t u;

  u = a * QINV;
  t = (int32_t)u * NTTRU_Q;
  t = a - t;
  t >>= 16;
  return t;
}

int16_t fqred16(int16_t a) {
  int16_t t;

  t = a & 0x1FFF;
  a >>= 13;
  t += (a << 9) - a;
  return t;
}

int16_t fqcsubq(int16_t a) {
  a += (a >> 15) & NTTRU_Q;
  a -= NTTRU_Q;
  a += (a >> 15) & NTTRU_Q;
  return a;
}

int16_t fqmul(int16_t a, int16_t b) {
  return fqmontred((int32_t)a*b);
}

int16_t fqinv(int16_t a) {
  unsigned int i;
  int16_t t;

  t = a;
  for(i = 1; i <= 12; ++i) {
    a = fqmul(a, a);
    if(i != 9) t = fqmul(t, a);
  }

  return t;
}

int16_t fquniform(void) {
  int16_t r;

  do {
    randombytes((unsigned char*) &r, 2);
    r &= 0x1FFF;
  } while(r >= NTTRU_Q);

  return r;
}
