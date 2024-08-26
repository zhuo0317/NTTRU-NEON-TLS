#ifndef NTRU_H
#define NTRU_H
#include "params.h"
#include "poly.h"
#include <stdint.h>

#define ntru_keygen NTTRU_NAMESPACE(ntru_keygen)
int ntru_keygen(poly *hhat, poly *fhat, const unsigned char *coins);
#define ntru_encrypt NTTRU_NAMESPACE(ntru_encrypt)
void ntru_encrypt(poly *chat,
                  const poly *hhat,
                  const poly *m,
                  const unsigned char *coins);
#define ntru_decrypt NTTRU_NAMESPACE(ntru_decrypt)
void ntru_decrypt(poly *m,
                  const poly *chat,
                  const poly *fhat);
#endif
