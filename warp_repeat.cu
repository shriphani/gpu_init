#include <stdio.h>
#include "moderngpu.cuh"

using namespace mgpu;

__global__
void warpRepeat(int *items, int *freqs, int *result, int *pos, int numItems, int numResults) {

	// tid 0 fetches the item and the frequency list
	int itemIdx = blockIdx.x;

	__shared__ int warpItem;
	__shared__ int warpFreq;

	if (threadIdx.x == 0) {

		warpItem = items[itemIdx];
		warpFreq = freqs[itemIdx];

		printf("Block id: %d\n", itemIdx);
	}

	__syncthreads();

	for (int i = threadIdx.x; i < warpFreq; i += 32) {
		int position = pos[itemIdx] + i;
		result[position] = warpItem;
	}
}


int *partitionAndRun(int *items, int *freqs, int N, int &resultSize, ContextPtr context) {

	int CTASize = 32;

	int *deviceItems, *deviceFreqs, *deviceResult, *devicePos;

	cudaMalloc( (void **)&deviceItems, N * sizeof(int));
	cudaMalloc( (void **)&deviceFreqs, N * sizeof(int));
	cudaMalloc( (void **)&devicePos, N * sizeof(int));

	cudaMemcpy( deviceItems, items, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( deviceFreqs, freqs, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( devicePos, freqs, N * sizeof(int), cudaMemcpyHostToDevice);

	ScanExc(devicePos, N, &resultSize, *context);

	cudaMalloc( (void **)&deviceResult, resultSize * sizeof(int));

	int numBlocks = N;

	printf("Num blocks: %d\n", numBlocks);

	int *result = new int[resultSize];

	warpRepeat<<<numBlocks, CTASize>>>(deviceItems, deviceFreqs, deviceResult, devicePos, N, resultSize);

	cudaMemcpy( result, deviceResult, resultSize * sizeof(int), cudaMemcpyDeviceToHost );

	cudaFree(deviceItems);
	cudaFree(deviceFreqs);
	cudaFree(deviceResult);
	cudaFree(devicePos);	


	return result;
}