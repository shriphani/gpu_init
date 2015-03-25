#include <stdio.h>
#include "moderngpu.cuh"

#define CTA_SIZE 256

using namespace mgpu;

__global__
void warpRepeat(int *items, int *freqs, int *result, int *pos, int numItems, int numResults) {

	const int nWarpsPerCTA = CTA_SIZE / 32;
	const int tid = threadIdx.x + (blockDim.x * blockIdx.x);
	const int wid = tid / 32;
	const int lane = tid % 32;
	const int lwid = wid % nWarpsPerCTA; 
	// tid 0 fetches the item and the frequency list
	int itemIdx = wid;

	if (itemIdx >= numItems)
		return;

	__shared__ int warpItem[CTA_SIZE / 32];
	__shared__ int warpFreq[CTA_SIZE / 32];

	if (lane == 0) {

		warpItem[lwid] = items[itemIdx];
		warpFreq[lwid] = freqs[itemIdx];

		//printf("Item it: %d\n, Item freq: %d\n", itemIdx, warpFreq);
	}

	__syncthreads();

	for (int i = lane; i < warpFreq[lwid]; i += 32) {
		//printf("item id: %d, freq: %d\n", lwid, warpFreq[lwid]);
		int position = pos[itemIdx] + i;
		result[position] = warpItem[lwid];
	}
}


int *partitionAndRun(int *items, int *freqs, int N, int &resultSize, ContextPtr context) {

	const int CTASize = 256;

	int *deviceItems, *deviceFreqs, *deviceResult, *devicePos;

	cudaMalloc( (void **)&deviceItems, N * sizeof(int));
	cudaMalloc( (void **)&deviceFreqs, N * sizeof(int));
	cudaMalloc( (void **)&devicePos, N * sizeof(int));

	cudaMemcpy( deviceItems, items, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( deviceFreqs, freqs, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( devicePos, freqs, N * sizeof(int), cudaMemcpyHostToDevice);

	ScanExc(devicePos, N, &resultSize, *context);

	cudaMalloc( (void **)&deviceResult, resultSize * sizeof(int));

	int numBlocks = (N * 32 + (CTASize - 1)) / CTA_SIZE;

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