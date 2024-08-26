#ifndef NTT_H
#define NTT_H

#include <stdint.h>
#define zetas_inv NTTRU_NAMESPACE(zetas_inv)
#define zetas NTTRU_NAMESPACE(zetas)
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


#define ntt NTTRU_NAMESPACE(ntt)
#define invntt NTTRU_NAMESPACE(invntt)
#define ntt_pack NTTRU_NAMESPACE(ntt_pack)
#define ntt_unpack NTTRU_NAMESPACE(ntt_unpack)
#define ntt_unpack NTTRU_NAMESPACE(ntt_unpack)
#define basemul NTTRU_NAMESPACE(basemul)
#define baseinv NTTRU_NAMESPACE(baseinv)
#define ntt_arm NTTRU_NAMESPACE(ntt_arm)
#define invntt_arm NTTRU_NAMESPACE(invntt_arm)
#define baseinv_arm NTTRU_NAMESPACE(baseinv_arm)
#define basemul_arm NTTRU_NAMESPACE(basemul_arm)
#define freeze_arm NTTRU_NAMESPACE(freeze_arm)
#define poly_fqred_arm NTTRU_NAMESPACE(poly_fqred_arm)

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
