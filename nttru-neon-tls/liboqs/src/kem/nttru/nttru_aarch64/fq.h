#ifndef REDUCE_H
#define REDUCE_H

#include <stdint.h>

#define MONT 4088 // 2^16 % NTTRU_Q
#define QINV 57857 // q^(-1) mod 2^16


#define fqmontred NTTRU_NAMESPACE(fqmontred)
#define fqred16 NTTRU_NAMESPACE(fqred16)
#define fqcsubq NTTRU_NAMESPACE(fqcsubq)
#define fqmul NTTRU_NAMESPACE(fqmul)
#define fqinv NTTRU_NAMESPACE(fqinv)
#define fquniform NTTRU_NAMESPACE(fquniform)
int16_t fqmontred(int32_t a);
int16_t fqred16(int16_t a);
int16_t fqcsubq(int16_t a);
int16_t fqmul(int16_t a, int16_t b);
int16_t fqinv(int16_t a);
int16_t fquniform(void);

#endif
