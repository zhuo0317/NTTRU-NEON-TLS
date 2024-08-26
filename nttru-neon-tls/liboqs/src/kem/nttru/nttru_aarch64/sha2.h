#ifndef SHA_2_H
#define SHA_2_H

#include <stddef.h>
#include <stdint.h>
#include "params.h"
#define sha512 NTTRU_NAMESPACE(sha512)
void sha512(uint8_t out[64], const uint8_t *in, size_t inlen);

#endif
