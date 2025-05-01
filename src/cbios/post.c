//This file handes post (Power on self test) and other system related functions


/********************************************************************************
   CPU Initialization
   1. CPU Initialization
Reset CPU (via RESET# line or INIT# signal)

Enable caches (L1/L2/L3) — very early caching

Check CPU signature (family/model/stepping)

Check CPU status flags (like errors, BIST results)

Detect multi-core / hyperthreading

Detect CPU features (SSE, AVX, virtualization support, etc.)

Setup CPU exception vectors
*******************************************************************************/

