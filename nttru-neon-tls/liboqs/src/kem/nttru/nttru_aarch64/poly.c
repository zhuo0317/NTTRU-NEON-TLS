#include <stdint.h>
#include "params.h"
#include "fq.h"
#include "ntt.h"
#include "poly.h"
#include <arm_neon.h>


void poly_reduce(poly *a) {
  unsigned int i;
  for(i = 0; i < NTTRU_N; ++i)
    a->coeffs[i] = fqred16(a->coeffs[i]);
}

void poly_freeze(poly *a) {
  unsigned int i;
  poly_reduce(a);
  for(i = 0; i < NTTRU_N; ++i)
    a->coeffs[i] = fqcsubq(a->coeffs[i]);
}

void poly_freeze0(poly *a) {//fqcsubq
  freeze_arm(a->coeffs, freeze_const);
}

void poly_fqred(poly *a) {//fqred
  poly_fqred_arm(a->coeffs, fqred_const);
}

void poly_add(poly *c, const poly *a, const poly *b) {
  unsigned int i;
  for(i = 0; i < NTTRU_N; ++i)
    c->coeffs[i] = a->coeffs[i] + b->coeffs[i];
}

void poly_triple(poly *b, poly *a) {
  unsigned int i;

  int16x8_t a_coeffs, b_coeffs;
  int16x8_t three = vdupq_n_s16(3);

  for(i = 0; i < NTTRU_N; i+=8)
  {
    a_coeffs = vld1q_s16(&a->coeffs[i]);
    b_coeffs = vmulq_s16(a_coeffs, three);
    vst1q_s16(&b->coeffs[i], b_coeffs);
  }
}
#define poly_triple0 NTTRU_NAMESPACE(poly_triple0)
void poly_triple0(poly *b, poly *a) {
  unsigned int i;
  for(i = 0; i < NTTRU_N; ++i)
    b->coeffs[i] = 3*a->coeffs[i];
}

void poly_ntt(poly *b) {
  ntt_arm(b->coeffs, zetas_arm);
}

void poly_ntt0(poly *b, const poly *a) {
  ntt(b->coeffs, a->coeffs);
}

void poly_invntt(poly *b) {
  invntt_arm(b->coeffs, zetas_inv_arm, zetas_inv_const);
}

void poly_basemul(poly *c, const poly *a, const poly *b) {
  basemul_arm(c->coeffs, a->coeffs, b->coeffs, zeta_base);
}

void poly_basemul0(poly *c, const poly *a, const poly *b) {
  unsigned int i;
  for(i = 0; i < NTTRU_N/6; ++i) {
    basemul(c->coeffs + 6*i, a->coeffs + 6*i, b->coeffs + 6*i, zetas[128 + i]);
    basemul(c->coeffs + 6*i + 3, a->coeffs + 6*i + 3, b->coeffs + 6*i + 3, -zetas[128 + i]);
  }
}

int poly_baseinv(poly *res, poly *b, poly *a) {
  int r = 0;
  res->coeffs[0]=0;
  baseinv_arm(res->coeffs, b->coeffs, a->coeffs, zeta_base);
  r=res->coeffs[0];
  return r;
}

int poly_baseinv0(poly *b, const poly *a) {
  unsigned int i;
  int r = 0;
  for(i = 0; i < NTTRU_N/6; ++i) {
    r += baseinv(b->coeffs + 6*i, a->coeffs + 6*i, zetas[128 + i]);
    r += baseinv(b->coeffs + 6*i + 3, a->coeffs + 6*i + 3, -zetas[128 + i]);
  }
  return r;
}

void poly_short(poly *a, const unsigned char buf[NTTRU_N/2]) {
  unsigned int i;
  unsigned char t;
  const uint16_t L = 0xA815;
 
  for(i = 0; i < NTTRU_N/2; ++i) {
    t = buf[i];
    a->coeffs[2*i + 0]  = (L >> (t & 0xF)) & 0x3;
    a->coeffs[2*i + 0] -= 1;
    a->coeffs[2*i + 1]  = (L >> (t >> 4)) & 0x3;
    a->coeffs[2*i + 1] -= 1;
  }

}

// Assumes -NTTRU_Q < a < NTTRU_Q
static int16_t crepmod3(int16_t a) {
  a += (a >> 15) & NTTRU_Q;
  a -= (NTTRU_Q-1)/2;
  a += (a >> 15) & NTTRU_Q;
  a -= (NTTRU_Q+1)/2;

  a  = (a >> 8) + (a & 255);
  a  = (a >> 4) + (a & 15);
  a  = (a >> 2) + (a & 3);
  a  = (a >> 2) + (a & 3);
  a -= 3;
  a += ((a + 1) >> 15) & 3;
  return a;
}

void poly_crepmod3(poly *b, const poly *a) {
  unsigned int i;

  for(i = 0; i < NTTRU_N; ++i)
    b->coeffs[i] = crepmod3(a->coeffs[i]);

}

void poly_pack_uniform(unsigned char *buf, const poly *a) {
  unsigned int i, j, k;
  int16_t t[16];
  poly b;

  b = *a;
  ntt_pack(b.coeffs, b.coeffs);

  for(i = 0; i < NTTRU_N/256; ++i) {
    for(j = 0; j < 16; ++j) {
      for(k = 0; k < 16; ++k)
        t[k] = b.coeffs[256*i + 16*k + j];

      buf[416*i + 2*j +   0] = (t[0] >>  0);
      buf[416*i + 2*j +   1] = (t[0] >>  8) + (t[1] << 5);
      buf[416*i + 2*j +  32] = (t[1] >>  3);
      buf[416*i + 2*j +  33] = (t[1] >> 11) + (t[2]  << 2);
      buf[416*i + 2*j +  64] = (t[2] >>  6) + (t[3]  << 7);
      buf[416*i + 2*j +  65] = (t[3] >>  1);
      buf[416*i + 2*j +  96] = (t[3] >>  9) + (t[4]  << 4);
      buf[416*i + 2*j +  97] = (t[4] >>  4);
      buf[416*i + 2*j + 128] = (t[4] >> 12) + (t[5]  << 1);
      buf[416*i + 2*j + 129] = (t[5] >>  7) + (t[6]  << 6);
      buf[416*i + 2*j + 160] = (t[6] >>  2);
      buf[416*i + 2*j + 161] = (t[6] >> 10) + (t[7]  << 3);
      buf[416*i + 2*j + 192] = (t[7] >>  5);
      buf[416*i + 2*j + 193] = (t[8] >>  0);
      buf[416*i + 2*j + 224] = (t[8] >>  8) + (t[9] << 5);
      buf[416*i + 2*j + 225] = (t[9] >>  3);
      buf[416*i + 2*j + 256] = (t[9] >> 11) + (t[10]  << 2);
      buf[416*i + 2*j + 257] = (t[10] >>  6) + (t[11]  << 7);
      buf[416*i + 2*j + 288] = (t[11] >>  1);
      buf[416*i + 2*j + 289] = (t[11] >>  9) + (t[12]  << 4);
      buf[416*i + 2*j + 320] = (t[12] >>  4);
      buf[416*i + 2*j + 321] = (t[12] >> 12) + (t[13]  << 1);
      buf[416*i + 2*j + 352] = (t[13] >>  7) + (t[14]  << 6);
      buf[416*i + 2*j + 353] = (t[14] >>  2);
      buf[416*i + 2*j + 384] = (t[14] >> 10) + (t[15]  << 3);
      buf[416*i + 2*j + 385] = (t[15] >>  5);
    }
  }

}

void poly_unpack_uniform(poly *a, const unsigned char *buf) {
  unsigned int i, j, k;
  unsigned char t[26];

  for(i = 0; i < NTTRU_N/256; ++i) {
    for(j = 0; j < 16; ++j) {
      for(k = 0; k < 26/2; ++k) {
        t[2*k] = buf[416*i + 2*j + 32*k];
        t[2*k+1] = buf[416*i + 2*j + 32*k + 1];
      }

      a->coeffs[256*i + j +   0]  = t[0];
      a->coeffs[256*i + j +   0] += ((int16_t)t[1] & 0x1f) << 8;
      a->coeffs[256*i + j +  16]  = t[1] >> 5;
      a->coeffs[256*i + j +  16] += (int16_t)t[2] << 3;
      a->coeffs[256*i + j +  16] += ((int16_t)t[3] & 0x03) << 11;
      a->coeffs[256*i + j +  32]  = t[3] >> 2;
      a->coeffs[256*i + j +  32] += ((int16_t)t[4] & 0x7f) << 6;
      a->coeffs[256*i + j +  48]  = t[4] >> 7;
      a->coeffs[256*i + j +  48] += (int16_t)t[5] << 1;
      a->coeffs[256*i + j +  48] += ((int16_t)t[6] & 0x0f) <<  9;
      a->coeffs[256*i + j +  64]  = t[6] >> 4;
      a->coeffs[256*i + j +  64] += (int16_t)t[7] << 4;
      a->coeffs[256*i + j +  64] += ((int16_t)t[8] & 0x01) << 12;
      a->coeffs[256*i + j +  80]  = t[8] >> 1;
      a->coeffs[256*i + j +  80] += ((int16_t)t[9] & 0x3f) << 7;
      a->coeffs[256*i + j +  96]  = t[9] >> 6;
      a->coeffs[256*i + j +  96] += (int16_t)t[10] << 2;
      a->coeffs[256*i + j +  96] += ((int16_t)t[11] & 0x07) << 10;
      a->coeffs[256*i + j + 112]  = t[11] >> 3;
      a->coeffs[256*i + j + 112] += (int16_t)t[12] << 5;
      a->coeffs[256*i + j + 128]  = t[13];
      a->coeffs[256*i + j + 128] += ((int16_t)t[14] & 0x1f) << 8;
      a->coeffs[256*i + j + 144]  = t[14] >> 5;
      a->coeffs[256*i + j + 144] += (int16_t)t[15] << 3;
      a->coeffs[256*i + j + 144] += ((int16_t)t[16] & 0x03) << 11;
      a->coeffs[256*i + j + 160]  = t[16] >> 2;
      a->coeffs[256*i + j + 160] += ((int16_t)t[17] & 0x7f) << 6;
      a->coeffs[256*i + j + 176]  = t[17] >> 7;
      a->coeffs[256*i + j + 176] += (int16_t)t[18] << 1;
      a->coeffs[256*i + j + 176] += ((int16_t)t[19] & 0x0f) <<  9;
      a->coeffs[256*i + j + 192]  = t[19] >> 4;
      a->coeffs[256*i + j + 192] += (int16_t)t[20] << 4;
      a->coeffs[256*i + j + 192] += ((int16_t)t[21] & 0x01) << 12;
      a->coeffs[256*i + j + 208]  = t[21] >> 1;
      a->coeffs[256*i + j + 208] += ((int16_t)t[22] & 0x3f) << 7;
      a->coeffs[256*i + j + 224]  = t[22] >> 6;
      a->coeffs[256*i + j + 224] += (int16_t)t[23] << 2;
      a->coeffs[256*i + j + 224] += ((int16_t)t[24] & 0x07) << 10;
      a->coeffs[256*i + j + 240]  = t[24] >> 3;
      a->coeffs[256*i + j + 240] += (int16_t)t[25] << 5;
    }
  }

  ntt_unpack(a->coeffs, a->coeffs);
}

void poly_pack_short(unsigned char *buf, const poly *a) {
  unsigned int i, j;
  unsigned char c;

  for(i = 0; i < NTTRU_N/128; ++i) {
    for(j = 0; j < 16; ++j) {
      c  = a->coeffs[128*i + 0 + j] + 1;
      c += (a->coeffs[128*i + 16 + j] + 1) << 2;
      c += (a->coeffs[128*i + 32 + j] + 1) << 4;
      c += (a->coeffs[128*i + 48 + j] + 1) << 6;
      buf[32*i + 2*j + 0] = c;

      c  = a->coeffs[128*i + 64 + j] + 1;
      c += (a->coeffs[128*i + 80 + j] + 1) << 2;
      c += (a->coeffs[128*i + 96 + j] + 1) << 4;
      c += (a->coeffs[128*i + 112 + j] + 1) << 6;
      buf[32*i + 2*j + 1] = c;
    }
  }

}

void poly_unpack_short(poly *a, const unsigned char *buf) {
  unsigned int i, j;
  unsigned char c;

  for(i = 0; i < NTTRU_N/128; ++i) {
    for(j = 0; j < 16; ++j) {
      c = buf[32*i + 2*j + 0];
      a->coeffs[128*i +   0 + j] = (int16_t)(c & 3) - 1;
      a->coeffs[128*i +  16 + j] = (int16_t)((c >> 2) & 3) - 1;
      a->coeffs[128*i +  32 + j] = (int16_t)((c >> 4) & 3) - 1;
      a->coeffs[128*i +  48 + j] = (int16_t)(c >> 6) - 1;

      c = buf[32*i + 2*j + 1];
      a->coeffs[128*i +  64 + j] = (int16_t)(c & 3) - 1;
      a->coeffs[128*i +  80 + j] = (int16_t)((c >> 2) & 3) - 1;
      a->coeffs[128*i +  96 + j] = (int16_t)((c >> 4) & 3) - 1;
      a->coeffs[128*i + 112 + j] = (int16_t)(c >> 6) - 1;
    }
  }
}
#define poly_pack_short_base3 NTTRU_NAMESPACE(poly_pack_short_base3)
void poly_pack_short_base3(unsigned char *buf, const poly *a) {
  unsigned int i;
  int j;
  unsigned char c;

  for(i = 0; i < NTTRU_N/5; i++) {
    c =       a->coeffs[5*i + 4] + 1;
    c = 3*c + a->coeffs[5*i + 3] + 1;
    c = 3*c + a->coeffs[5*i + 2] + 1;
    c = 3*c + a->coeffs[5*i + 1] + 1;
    c = 3*c + a->coeffs[5*i + 0] + 1;
    buf[i] = c;
  }

  i = NTTRU_N/5;
  c = 0;
  for(j = NTTRU_N - (5*i) - 1; j >= 0; --j)
    c = 3*c + a->coeffs[5*i + j] + 1;
  buf[i] = c;

}

static int16_t mod3(int16_t a) {
  a  = (a >> 8) + (a & 255);
  a  = (a >> 4) + (a & 15);
  a  = (a >> 2) + (a & 3);
  a = (a >> 2) + (a & 3);
  a -= 3;
  a += (a >> 15) & 3;
  return a;
}
#define poly_unpack_short_base3 NTTRU_NAMESPACE(poly_unpack_short_base3)
void poly_unpack_short_base3(poly *a, const unsigned char *buf) {
  unsigned int i, j;
  unsigned char c;

  for(i = 0; i < NTTRU_N/5; i++) {
    c = buf[i];
    a->coeffs[5*i + 0] = mod3(c) - 1;
    a->coeffs[5*i + 1] = mod3(c*171 >> 9) - 1;
    a->coeffs[5*i + 2] = mod3(c*57 >> 9) - 1;
    a->coeffs[5*i + 3] = mod3(c*19 >> 9) - 1;
    a->coeffs[5*i + 4] = mod3(c*203 >> 14) - 1;
  }

  i = NTTRU_N/5;
  c = buf[i];
  for(j = 0; (5*i + j) < NTTRU_N; ++j) {
    a->coeffs[5*i + j] = mod3(c) - 1;
    c = c * 171 >> 9;
  }
}
