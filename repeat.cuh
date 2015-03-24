#include <stdio.h>
#include "moderngpu.cuh"

using namespace mgpu;

int *partitionAndRun(int *items, int *freqs, int N, int &resultSize, ContextPtr context);