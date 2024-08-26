# SPDX-License-Identifier: MIT

set(_NTTRU_OBJS "")

if(OQS_ENABLE_KEM_nttru)
    add_library(nttru OBJECT kem_nttru.c nttru_aarch64/aes256ctr.c nttru_aarch64/baseinv_arm.S nttru_aarch64/basemul_arm.S nttru_aarch64/fq.c nttru_aarch64/fqred_arm.S nttru_aarch64/freeze_arm.S nttru_aarch64/invntt_arm.S nttru_aarch64/kem.c nttru_aarch64/macros.inc nttru_aarch64/ntru.c nttru_aarch64/ntt_arm.S nttru_aarch64/ntt.c nttru_aarch64/poly.c nttru_aarch64/sha512.c nttru_aarch64/verify.c)
    target_include_directories(nttru PRIVATE ${CMAKE_CURRENT_LIST_DIR}/nttru_aarch64)
    if (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        target_compile_definitions(nttru PRIVATE old_gas_syntax)
    endif()
    set(_NTTRU_OBJS ${_NTTRU_OBJS} $<TARGET_OBJECTS:nttru>)
endif()
set(NTTRU_OBJS ${_NTTRU_OBJS} PARENT_SCOPE)

