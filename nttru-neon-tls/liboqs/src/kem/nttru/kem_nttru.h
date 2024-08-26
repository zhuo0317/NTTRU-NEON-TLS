// SPDX-License-Identifier: MIT

#ifndef OQS_KEM_NTTRU_H
#define OQS_KEM_NTTRU_H

#include <oqs/oqs.h>

#ifdef OQS_ENABLE_KEM_nttru
#define OQS_KEM_nttru_length_public_key 1248
#define OQS_KEM_nttru_length_secret_key 2496
#define OQS_KEM_nttru_length_ciphertext 1248
#define OQS_KEM_nttru_length_shared_secret 32
OQS_KEM *OQS_KEM_nttru_new(void);
OQS_API OQS_STATUS OQS_KEM_nttru_keypair(uint8_t *public_key, uint8_t *secret_key);
OQS_API OQS_STATUS OQS_KEM_nttru_encaps(uint8_t *ciphertext, uint8_t *shared_secret, const uint8_t *public_key);
OQS_API OQS_STATUS OQS_KEM_nttru_decaps(uint8_t *shared_secret, const uint8_t *ciphertext, const uint8_t *secret_key);
#endif

#endif

