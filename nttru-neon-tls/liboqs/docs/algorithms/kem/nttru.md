# NTTRU

- **Algorithm type**: Key encapsulation mechanism.
- **Main cryptographic assumption**: NTRU.
- **Principal submitters**: China.
- **Auxiliary submitters**: China.
- **Authors' website**: https://pq-crystals.org/
- **Specification version**: NIST Round 3 submission.
- **Primary Source**<a name="primary-source"></a>:
  - **Source**: https://fdu.com with copy_from_upstream patches
  - **Implementation license (SPDX-Identifier)**: CC0-1.0 or Apache-2.0



## Parameter set summary

|  Parameter set  | Security model   |   Claimed NIST Level |   Public key size (bytes) |   Secret key size (bytes) |   Ciphertext size (bytes) |   Shared secret size (bytes) |
|:---------------:|:-----------------|---------------------:|--------------------------:|--------------------------:|--------------------------:|-----------------------------:|
|    NTTRU        | IND-CCA2         |                    3 |                      1248 |                      2496 |                      1248 |                           32 |


## NTTRU implementation characteristics

|           Implementation source           | Identifier in upstream   | Supported architecture(s)   | Supported operating system(s)   | CPU extension(s) used   | No branching-on-secrets claimed?   | No branching-on-secrets checked by valgrind?   | Large stack usage?   |
|:-----------------------------------------:|:-------------------------|:----------------------------|:--------------------------------|:------------------------|:-----------------------------------|:-----------------------------------------------|:---------------------|
|     [aarch64](#aarch64)                   | aarch64                  | ARM64\_V8                   | Linux,Darwin                    | None                    | True                               | True                                           | False                |


Are implementations chosen based on runtime CPU feature detection? **Yes**.

## Explanation of Terms

- **Large Stack Usage**: Implementations identified as having such may cause failures when running in threads or in constrained environments.