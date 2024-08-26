#ifndef NTT_H
#define NTT_H

#include <stdint.h>

extern int16_t zetas[256];
extern int16_t zetas_inv[256];
extern int16_t zetas_exp[1084];
extern int16_t zetas_inv_exp[1084];
extern const int16_t zetas_arm[417];
extern const int16_t zeta_base[256];
extern const int16_t zetas_inv_arm[417];
extern const int16_t zetas_inv_const[3];
extern const int16_t freeze_const[1];

extern const int16_t fqred_const[2];//fqred

void init_ntt();
void ntt(int16_t b[768], const int16_t a[768]);
void invntt(int16_t b[768], const int16_t a[768]);
void ntt_pack(int16_t b[768], const int16_t a[768]);
void ntt_unpack(int16_t b[768], const int16_t a[768]);
void basemul(int16_t c[3],
             const int16_t a[3],
             const int16_t b[3],
             int16_t zeta);
int baseinv(int16_t b[3], const int16_t a[3], int16_t zeta);
void ntt_arm(int16_t *poly, const int16_t* zetas);
void invntt_arm(int16_t *poly, const int16_t* zetas_inv, const int16_t* zetas_const);
int baseinv_arm(int16_t *poly, int16_t *poly1, int16_t *poly2, const int16_t* zeta);
void basemul_arm(int16_t *poly, const int16_t *poly1, const int16_t *poly2, const int16_t* zeta);
void freeze_arm(int16_t *poly, const int16_t* zetas);
void poly_fqred_arm(int16_t *poly, const int16_t* zetas);
#endif
