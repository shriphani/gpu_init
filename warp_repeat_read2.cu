#include <stdio.h>
#include "moderngpu.cuh"

#define CTA_SIZE 256
#define WARP_SIZE 32

using namespace mgpu;

__global__
void warpRepeat3(int *items, int *freqs, int *result, int *pos, int numItems, int numResults) {

    const int nWarpsPerCTA = CTA_SIZE / WARP_SIZE;
    const int tid = threadIdx.x + (blockDim.x * blockIdx.x);
    const int wid = tid / WARP_SIZE;
    const int lane = tid % WARP_SIZE;
    const int lwid = wid % nWarpsPerCTA;

    volatile __shared__ int ctaItem[CTA_SIZE];
    volatile __shared__ int ctaFreq[CTA_SIZE];
    volatile __shared__ int ctaPos[CTA_SIZE];

    // populate the block-specific shared mem items

    if (tid < numItems) {

        ctaItem[threadIdx.x] = items[tid];
        ctaFreq[threadIdx.x] = freqs[tid];
        ctaPos[threadIdx.x] = pos[tid];
    }

    // thunk executed by a warp
    for (int idx = 0; idx < WARP_SIZE; idx++) { // loop over all elements written by this warp
        // current thread reads out whatever it wrote
        // to shared mem.
        int currentThreadItem = (lwid * WARP_SIZE) + idx;

        //if (idx == 0)
            //printf("Current warp: %d, current idx: %d, item: %d, freq: %d\n", lwid, idx, ctaItem[currentThreadItem], ctaFreq[currentThreadItem]);

        for (int i = lane; i < ctaFreq[currentThreadItem]; i++) {
            int position = ctaPos[currentThreadItem] + i;
            //printf("Position: %d\n", position);
            result[position] = ctaItem[currentThreadItem];
        }

    }
}


int *partitionAndRun(int *items, int *freqs, int N, int &resultSize, ContextPtr context) {

	int *deviceItems, *deviceFreqs, *deviceResult, *devicePos;

	cudaMalloc( (void **)&deviceItems, N * sizeof(int));
	cudaMalloc( (void **)&deviceFreqs, N * sizeof(int));
	cudaMalloc( (void **)&devicePos, N * sizeof(int));

	cudaMemcpy( deviceItems, items, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( deviceFreqs, freqs, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy( devicePos, freqs, N * sizeof(int), cudaMemcpyHostToDevice);

	ScanExc(devicePos, N, &resultSize, *context);

	cudaMalloc( (void **)&deviceResult, resultSize * sizeof(int));

	int numBlocks = (N * WARP_SIZE + (CTA_SIZE - 1)) / CTA_SIZE;

	printf("Num blocks: %d\n", numBlocks);

	int *result = new int[resultSize];

	warpRepeat3<<<numBlocks, CTA_SIZE>>>(deviceItems, deviceFreqs, deviceResult, devicePos, N, resultSize);

	cudaMemcpy( result, deviceResult, resultSize * sizeof(int), cudaMemcpyDeviceToHost );

	cudaFree(deviceItems);
	cudaFree(deviceFreqs);
	cudaFree(deviceResult);
	cudaFree(devicePos);


	return result;
}
