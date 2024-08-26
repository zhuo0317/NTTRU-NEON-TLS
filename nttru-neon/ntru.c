#include "randombytes.h"
#include "params.h"
#include "poly.h"
poly res;
int ntru_keygen(poly *hhat, poly *fhat, const unsigned char coins[N]) {
  int r;
  poly f, g;
  poly res;

  poly_short(&f, coins);
  poly_short(&g, coins + N/2);
  poly_triple(&g, &g);
  poly_triple(&f, &f);
  f.coeffs[0] += 1;
    
  for(int i=0; i<768; i++){
    fhat->coeffs[i]=f.coeffs[i];
  }
  poly_ntt(fhat);
  poly_ntt(&g);
  //poly_freeze(fhat);
  poly_fqred(fhat);
  poly_freeze0(fhat);
  r = poly_baseinv(&res, &f, fhat);
  //r = poly_baseinv0(&f, fhat);
  poly_fqred(&g);
  poly_basemul(hhat, &f, &g);
  //poly_basemul(hhat, &f, &g);
  //poly_freeze(hhat);
  poly_fqred(hhat);
  poly_freeze0(hhat);
  return r;
}

void ntru_encrypt(poly *chat,
                  const poly *hhat,
                  const poly *m,
                  const unsigned char coins[N/2])
{
  poly r, mhat;

  poly_short(&r, coins);
  poly_ntt(&r);
  for(int i=0; i<768; i++){
    mhat.coeffs[i]=m->coeffs[i];
  }
  poly_ntt(&mhat);
  poly_fqred(&r);
  poly_basemul(chat, &r, hhat);
  //poly_basemul(chat, &r, hhat);
  poly_fqred(chat);
  //poly_reduce(chat);
  poly_add(chat, chat, &mhat);
  //poly_freeze(chat);
  poly_fqred(chat);
  poly_freeze0(chat);
}

void ntru_decrypt(poly *m,
                  const poly *chat,
                  const poly *fhat)
{
  poly_basemul(m, chat, fhat);
  poly_fqred(m);
  poly_invntt(m);
  poly_crepmod3(m, m);
}
