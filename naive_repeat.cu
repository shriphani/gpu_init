#include <stdio.h>
#include "moderngpu.cuh"

using namespace mgpu;

__global__
void simpleMerge(int *items, int *freqs, int *result, int *pos, int numItems) {

	int gid = threadIdx.x + blockIdx.x * blockDim.x;

	if (gid > numItems) {
		return;
	}

	//printf("ThreadId: %d", gid);

	int item = items[gid];
	int freq = freqs[gid];

	int position = pos[gid];

	//printf( "Put %d at %d, %d times\n", item, position, freq );

	for (int i = 0; i < freq; i++) {
		result[position+i] = item;
	}
}

int *partitionAndRun(int *items, int *freqs, int N, int &resultSize, ContextPtr context) {
	int CTASize = 1024;
	int numBlocks = 1 + (N / CTASize);

	int *deviceItems, *deviceFreqs, *deviceResult, *devicePos;

	cudaMalloc( (void **)&deviceItems, N * sizeof(int));
	cudaMalloc( (void **)&deviceFreqs, N * sizeof(int));
	cudaMalloc( (void **)&devicePos, N * sizeof(int));

	cudaMemcpy( deviceItems, items, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( deviceFreqs, freqs, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( devicePos, freqs, N * sizeof(int), cudaMemcpyHostToDevice);

	ScanExc(devicePos, N, &resultSize, *context);

	cudaMalloc( (void **)&deviceResult, resultSize * sizeof(int));

#ifdef PROFILING
	cudaProfilerStart();
#endif

	simpleMerge<<<numBlocks, CTASize>>>(deviceItems, deviceFreqs, deviceResult, devicePos, N);

#ifdef PROFILING
	cudaProfilerStop();
#endif


	int *result = new int[resultSize];

	cudaMemcpy( result, deviceResult, resultSize * sizeof(int), cudaMemcpyDeviceToHost );

	cudaFree(deviceItems);
	cudaFree(deviceFreqs);
	cudaFree(deviceResult);
	cudaFree(devicePos);

	return result;
}
