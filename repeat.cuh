#include <stdio.h>
#include "moderngpu.cuh"

// uncomment to profile everything
#define PROFILING 1

#ifdef PROFILING
#include <cuda_profiler_api.h>
#endif

using namespace mgpu;

int *partitionAndRun(int *items, int *freqs, int N, int &resultSize, ContextPtr context);