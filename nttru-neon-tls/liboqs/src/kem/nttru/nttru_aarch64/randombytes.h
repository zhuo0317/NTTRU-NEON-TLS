#ifndef RANDOMBYTES_H
#define RANDOMBYTES_H

#define _GNU_SOURCE

//#include <unistd.h>
//void randombytes(unsigned char *x, unsigned long long xlen);
#include <oqs/rand.h>
#define randombytes OQS_randombytes
#endif
