#ifndef POLY_H
#define POLY_H

#include <stdint.h>
#include "params.h"

#define POLY_PACKED_UNIFORM_BYTES (NTTRU_LOGQ*NTTRU_N/8)
#define POLY_PACKED_SHORT_BYTES (NTTRU_LOGQ*NTTRU_N/8)

typedef struct {
  int16_t coeffs[NTTRU_N];
} poly __attribute__((aligned(32)));





#define poly_reduce NTTRU_NAMESPACE(poly_reduce)
#define poly_freeze NTTRU_NAMESPACE(poly_freeze)
#define poly_freeze0 NTTRU_NAMESPACE(poly_freeze0)
#define poly_fqred NTTRU_NAMESPACE(poly_fqred)
#define poly_add NTTRU_NAMESPACE(poly_add)
#define poly_triple NTTRU_NAMESPACE(poly_triple)
#define poly_ntt NTTRU_NAMESPACE(poly_ntt)
#define poly_ntt0 NTTRU_NAMESPACE(poly_ntt0)
#define poly_invntt NTTRU_NAMESPACE(poly_invntt)
#define poly_basemul NTTRU_NAMESPACE(poly_basemul)
#define poly_basemul0 NTTRU_NAMESPACE(poly_basemul0)
#define poly_baseinv NTTRU_NAMESPACE(poly_baseinv)
#define poly_baseinv0 NTTRU_NAMESPACE(poly_baseinv0)
#define poly_uniform NTTRU_NAMESPACE(poly_uniform)
#define poly_short NTTRU_NAMESPACE(poly_short)
#define poly_crepmod3 NTTRU_NAMESPACE(poly_crepmod3)
#define poly_pack_uniform NTTRU_NAMESPACE(poly_pack_uniform)
#define poly_unpack_uniform NTTRU_NAMESPACE(poly_unpack_uniform)
#define poly_pack_short NTTRU_NAMESPACE(poly_pack_short)
#define poly_unpack_short NTTRU_NAMESPACE(poly_unpack_short)

void poly_reduce(poly *a);
void poly_freeze(poly *a);
void poly_freeze0(poly *a);
void poly_fqred(poly *a);

void poly_add(poly *c, const poly *a, const poly *b);
void poly_triple(poly *b, poly *a);
void poly_ntt(poly *b);
void poly_ntt0(poly *b, const poly *a);
void poly_invntt(poly *b);
void poly_basemul(poly *c, const poly *a, const poly *b);
void poly_basemul0(poly *c, const poly *a, const poly *b);
int poly_baseinv(poly *res, poly *b, poly *a);
int poly_baseinv0(poly *b, const poly *a);
void poly_uniform(poly *a, const unsigned char *buf);
void poly_short(poly *a, const unsigned char *buf);

void poly_crepmod3(poly *b, const poly *a);

void poly_pack_uniform(unsigned char *buf, const poly *a);
void poly_unpack_uniform(poly *a, const unsigned char *buf);
void poly_pack_short(unsigned char *buf, const poly *a);
void poly_unpack_short(poly *a, const unsigned char *buf);

#endif
